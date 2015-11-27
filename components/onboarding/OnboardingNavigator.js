let React = require('react-native');
var Button = require('react-native-button');

let {
  AppRegistry,
  AlertIOS,
  Navigator,
  Text,
  TouchableOpacity,
  StyleSheet,
  WebView,
} = React;

let CookieManager = require('react-native-cookies');

// Native
let BridgeManager = require('../../modules/BridgeManager');
let Analytics = require('../../modules/Analytics');

let SHEET = require('../CommonStyles').SHEET;
let HashtagListView = require('../lib/HashtagListView');
let FacebookLoginScreen = require('./FacebookLoginScreen');
let LinkServiceScreen = require('./LinkServiceScreen');
let EditProfileScreen = require('./EditProfileScreen');
let AddHashtagScreen = require('./AddHashtagScreen');
let JoinNetworkScreen = require('./JoinNetworkScreen');
let TSNavigationBar = require('../lib/TSNavigationBar');

class OnboardingNavigator extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      editProfileCurrentlyFocused: false,
    };
  }

  onEditProfileChange(activeText) {
    this.setState({ activeText: activeText });
  }

  onEditProfileFocus(key) {
    this.setState({
      editProfileCurrentlyFocused: true,
      editProfileKey: key,
    }) 
  }

  onEditProfileBlur() {
    this.setState({ editProfileCurrentlyFocused: false }) 
  }

  displayError(message) {
    AlertIOS.alert('Missing Some Info', message);
  }

  _title(route, navigator, index, navState) {
    return (
      <Text style={[styles.navBarText, styles.navBarTitleText, SHEET.baseText]}>
        {route.title}
      </Text>
    );
  }

  _onNavigationStateChange(nav, navState) {
    if (navState.url.indexOf(BridgeManager.bundleUrlScheme()) != -1) {
      return nav.pop();
    }
  }

  _leftButton(route, navigator, index, navState) {
    switch (route.id) {
      case 'login':
        return null;

      default:
        return (
          <TouchableOpacity
            onPress={() => navigator.pop()}
            style={styles.navBarLeftButton}>
            <Text style={[SHEET.navBarText, SHEET.navBarButtonText, SHEET.baseText]}>
              Back
            </Text>
          </TouchableOpacity>
        );
    }
  }

  _rightButton(route, navigator, index, navState) {
    let me = this.props.me;
    let myTags = this.props.myTags;

    var buttonText = 'Next';
    var action = null;
    switch (route.id) {
      case 'linkservicecontainer':
        if (me && me.connectedProfiles.length > 0) {
          action = () => {
            Analytics.track('Signup: Add Integrations');
            navigator.push({
              id: 'editprofile',
              title: 'Edit Profile',
              me: me,
            })
          }
        }
        break;

      case 'editprofile':
        action = () => {
          if (!me.firstName) {
            this.displayError('Please fill in a first name.')
          } else if (!me.lastName) {
            this.displayError('What happened to your last name?')
          } else  if (!me.hometown) {
            this.displayError('Where are you from? Please fill in a hometown.')
          } else if (!me.major) {
            this.displayError('What are you studying? Fill in a major.')
          } else if (!me.gradYear) {
            this.displayError('When are you graduating? Please fill in a grad year. (i.e. \'19 or 2019)');
          } else {
            let saveActiveEditing = this.state.editProfileCurrentlyFocused ?
              this.props.updateProfile(this.state.editProfileKey, this.state.activeText) :
              Promise.resolve(true);

            saveActiveEditing.then(() => {
              return this.props.ddp.call({ methodName: 'completeProfile' })
            })
            .then(() => {
              Analytics.track('Signup: Create Profile');
              navigator.push({
                id: 'hashtags',
                title: 'Describe Yourself',
                me: me,
              })
            })
            .catch(err => {
              this.displayError(err.reason)
            })
          }
        }
        break;

      case 'campuswidelogin':
        if (!this.state.cwl) {
          return null;
        }

        action = () => {
          Analytics.track('Signup: Verify CWL');
          navigator.push({
            id: 'linkservicecontainer',
            title: 'Connect Services',
          })
        }
        break;

      case 'hashtags':
        buttonText = 'Done';
        action = () => {
          Analytics.track('Signup: Add Hashtags');
          if (myTags && myTags.length > 0) {
            this.props.ddp.call({ methodName: 'confirmRegistration' })
            .then(() => {
              Analytics.track('Signup: Done');
            })
          } else {
            this.displayError('You\'re so close! Please add at least one tag.')
          }
        }
        break;

      case 'joinnetwork':
      case 'addhashtag':
      case 'linkservice':
      case 'openwebview':
      case 'hashtag':
      case 'login': // fallthrough intentional
        return null;
    }

    return (
      <TouchableOpacity
        onPress={action}
        style={styles.navBarRightButton}>
        <Text style={[SHEET.navBarText, SHEET.navBarButtonText, SHEET.baseText]}>
          {buttonText} 
        </Text>
      </TouchableOpacity>
    );
  }

  hideNavBar() {
    this.setState({ navStyleOverride: { backgroundColor: 'rbga:(0,0,0,0)' }});
  }

  proceedIfLoginTokenPresent(nav, cookieName) {
    // list cookies
    return new Promise((resolve) => {
      CookieManager.getAll((cookies, res) => {
        if (cookies && cookies[cookieName]) {
          this.props.ddp.call({
            methodName: 'network/join',
            params: [cookies[cookieName].value]
          });
          this.setState({ cwl: true })
        }
        return resolve(true)
     });
    })
  }

  renderScene(route, nav) {
    switch (route.id) {
      case 'login':
        Analytics.screen('Welcome');
        return (
          <FacebookLoginScreen
            navigator={nav}
            me={this.props.me}
            loggedIn={this.props.loggedIn}
            onLogin={this.props.onLogin}
            onLogout={this.props.onLogout}
            isCWLRequired={this.props.isCWLRequired}
            ddp={this.props.ddp} />
        );

      case 'linkservicecontainer':
        Analytics.screen('ConnectServices');
        return (
          <LinkServiceScreen navigator={nav}
            integrations={this.props.integrations}
            me={this.props.me} // TEMP
            ddp={this.props.ddp} />
        );

      case 'editprofile':
        Analytics.screen('CreateProfile');
        return <EditProfileScreen 
          onEditProfileChange={this.onEditProfileChange.bind(this)}
          onEditProfileFocus={this.onEditProfileFocus.bind(this)}
          onEditProfileBlur={this.onEditProfileBlur.bind(this)}
          updateProfile={this.props.updateProfile}
          ddp={this.props.ddp}
          me={this.props.me} />

      case 'joinnetwork':
        Analytics.screen('JoinNetwork');
        return <JoinNetworkScreen
          navigator={nav}
          startInLoadingState={true} />

      case 'campuswidelogin':
        Analytics.screen('CWL');

        let url = 'https://cas.id.ubc.ca/ubc-cas/login';
        let cookieName = 'CASTGC';
        if (this.props.settings && this.props.settings.cwlURL) {
          let { cwlURL, cwlCookieName } = this.props.settings;
          if (cwlURL) {
            url = cwlURL.value;
          }

          if (cwlCookieName) {
            cookieName = cwlCookieName.value;
          }
        }

        return <WebView
          style={styles.webView}
          onNavigationStateChange={(navState) => {
            if (!navState.loading && navState.title) {
              this.proceedIfLoginTokenPresent(nav, cookieName)
              .then(() => {
                if (this.state.cwl) {
                  Analytics.track('Signup: Verify CWL');
                  nav.push({
                    id: 'linkservicecontainer',
                    title: 'Connect Services',
                  });
                }
              })
            }
          }}
          startInLoadingState={true}
          url={url} />;

      case 'linkservice':
        Analytics.screen("Link Integration", {
            "Name" : route.integration.name
        })
        return <WebView
          style={styles.webView}
          onNavigationStateChange={(navState) => this._onNavigationStateChange(nav, navState)}
          startInLoadingState={true}
          url={route.link} />;

      case 'hashtags':
        Analytics.screen("All Hashtag Categories")
        return <AddHashtagScreen navigator={nav}
          me={this.props.me}
          categories={this.props.categories}
          myTags={this.props.myTags}
          ddp={this.props.ddp} />

      case 'addhashtag':
        Analytics.screen("Edit Hashtag By Category", {
          category: route.category
        });
        return <HashtagListView
          style={{ flex: 1 }} 
          navigator={nav}
          removeBottomPadding={true}x
          ddp={this.props.ddp}
          myTags={this.props.myTags}
          category={route.category} />;

      case 'openwebview':
        Analytics.screen("Website", {
          "URL" : route.url
        })
        return <WebView
          style={styles.webView}
          startInLoadingState={true}
          url={route.url} />;

      case 'viewintegration':
        Analytics.screen("Integration Details", {
          "Name" : route.integration.name
        })
        return <WebView
          style={styles.webView}
          startInLoadingState={true}
          url={route.url} />;

    } 
  }

  render() {
    let initialRoute = {
      id: 'login',
    };

    return (
      <Navigator
        itemWrapperStyle={styles.navWrap}
        style={styles.nav}
        renderScene={this.renderScene.bind(this)}
        configureScene={(route) => ({
          ...Navigator.SceneConfigs.HorizontalSwipeJump,
          gestures: {}, // or null
        })}
        initialRoute={ initialRoute }
        navigationBar={
          <TSNavigationBar
            omitRoutes={['login']}
            routeMapper={{
              LeftButton: this._leftButton.bind(this),
              RightButton: this._rightButton.bind(this),
              Title: this._title.bind(this)
            }}
            style={styles.navBar} />
        }>
      </Navigator>
    )
  }
}

var styles = StyleSheet.create({
  navWrap: {
    flex: 1,
  },
  webView: {
    marginTop: 60,
    paddingTop: 60,
  },
  nav: {
    flex: 1,
  },
  moreButton: {
    width: 200,
    height: 200,
    position: 'absolute',
    top: 0,
    right: 0
  },
  navBar: {
    backgroundColor: '#64369C',
  },
  navBarTitleText: {
    fontSize: 20,
    color:  'white',
    fontWeight: '500',
    marginVertical: 9,
  },
  navBarText: {
    color: 'white',
    fontSize: 16,
    marginVertical: 10,
  },
  navBarLeftButton: {
    paddingLeft: 10,
  },
  navBarRightButton: {
    flex: 1,
    flexDirection: 'row',
    height: 64,
    alignItems: 'center',
    paddingRight: 10,
  },
});


module.exports = OnboardingNavigator;