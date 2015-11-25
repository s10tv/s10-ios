let React = require('react-native');
var Button = require('react-native-button');

let {
  AppRegistry,
  Navigator,
  Text,
  TouchableOpacity,
  StyleSheet,
  WebView,
} = React;

let CookieManager = require('react-native-cookies');

let BaseTaylrNavigator = require('../lib/BaseTaylrNavigator');
let SHEET = require('../CommonStyles').SHEET;
let HashtagListView = require('../lib/HashtagListView');
let FacebookLoginScreen = require('./FacebookLoginScreen');
let LinkServiceScreen = require('./LinkServiceScreen');
let EditProfileScreen = require('./EditProfileScreen');
let AddHashtagScreen = require('./AddHashtagScreen');
let JoinNetworkScreen = require('./JoinNetworkScreen');
let TSNavigationBar = require('../lib/TSNavigationBar');

class OnboardingNavigator extends BaseTaylrNavigator {

  constructor(props) {
    super(props);
    this.state = {};
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

  displayError(title, message) {
    alert(message);
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
            this.displayError('Error', 'FirstName not specified')
          } else if (!me.lastName) {
            this.displayError('Error', 'last name not specified')
          } else  if (!me.hometown) {
            this.displayError('Error', 'hometown not specified')
          } else if (!me.major) {
            this.displayError('Error', 'major not specified')
          } else if (!me.gradYear) {
            this.displayError('Error', 'gradyear not specified')
          } else {
            navigator.push({
              id: 'hashtags',
              title: 'Add Hashtags',
              me: me,
            })
          }
        }
        break;

      case 'campuswidelogin':
        if (!this.state.cwl) {
          return null;
        }

        action = () => {
          navigator.push({
            id: 'linkservicecontainer',
            title: 'Link Service',
          })
        }
        break;

      case 'hashtags':
        buttonText = 'Done';
        if (myTags && myTags.length > 0) {
          action = () => {
            this.props.ddp.call({ methodName: 'confirmRegistration' });
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

  proceedIfLoginTokenPresent(nav) {
    // list cookies
    return new Promise((resolve) => {
      CookieManager.getAll((cookies, res) => {
        if (cookies && cookies.CASTGC) {
          this.setState({ cwl: true })
        }
        return resolve(true)
      });
    })

  }

  renderScene(route, nav) {
    switch (route.id) {
      case 'login':
        return (
          <FacebookLoginScreen
            navigator={nav}
            me={this.props.me}
            loggedIn={this.props.loggedIn}
            onLogin={this.props.onLogin}
            ddp={this.props.ddp} />
        );

      case 'linkservicecontainer':
        return (
          <LinkServiceScreen navigator={nav}
            integrations={this.props.integrations}
            me={this.props.me} // TEMP
            ddp={this.props.ddp} />
        );

      case 'editprofile':
        return <EditProfileScreen 
          ddp={this.props.ddp}
          me={this.props.me} />

      case 'joinnetwork': 
        return <JoinNetworkScreen
          navigator={nav}
          startInLoadingState={true} />

      case 'campuswidelogin':
        return <WebView
          style={styles.webView}
          onNavigationStateChange={(navState) => {
            console.log(navState);
            if (!navState.loading && navState.title) {
              this.proceedIfLoginTokenPresent(nav)
              .then(() => {
                if (this.state.cwl) {
                  nav.push({
                    id: 'linkservicecontainer',
                    title: 'Link Service',
                  });
                }
              })
            }
          }}
          startInLoadingState={true}
          url={'https://cas.id.ubc.ca/ubc-cas/login'} />;

      case 'linkservice':
        return <WebView
          style={styles.webView}
          onNavigationStateChange={(navState) => this._onNavigationStateChange(nav, navState)}
          startInLoadingState={true}
          url={route.link} />;

      case 'hashtags':
        return <AddHashtagScreen navigator={nav}
          me={this.props.me}
          categories={this.props.categories}
          myTags={this.props.myTags}
          ddp={this.props.ddp} />

      case 'addhashtag':
        return <HashtagListView
          style={{ flex: 1 }} 
          navigator={nav}
          removeBottomPadding={true}x
          ddp={this.props.ddp}
          myTags={this.props.myTags}
          category={route.category} />;

      case 'openwebview':
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