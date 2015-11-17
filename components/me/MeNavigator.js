let React = require('react-native');
var Button = require('react-native-button');

let {
  AppRegistry,
  Navigator,
  Text,
  TouchableOpacity,
  StyleSheet,
} = React;

let SHEET = require('../CommonStyles').SHEET;
let Me = require('./Me');
let MeEdit = require('./MeEdit');
let Activities = require('../lib/Activities');
let HashtagListView =require('../lib/HashtagListView');

class MeNavigator extends React.Component {
  constructor(props) {
    super(props);
    this.ddp = props.ddp;
  }

  _leftButton(route, navigator, index, navState) {
    if (route.id) {
      return (
        <TouchableOpacity
          onPress={() => navigator.pop()}
          style={styles.navBarLeftButton}>
          <Text style={[styles.navBarText, styles.navBarButtonText, SHEET.baseText]}>
            Back
          </Text>
        </TouchableOpacity>
      );
    }
  }

  _rightButton(route, navigator, index, navState) {
    return null;
  }

  _title(route, navigator, index, navState) {
    return (
      <Text style={[styles.navBarText, styles.navBarTitleText, SHEET.baseText]}>
        {route.title}
      </Text>
    );
  }

  _onNavigationStateChange(nav, navState) {
    if (navState.url.indexOf('taylr-dev://') != -1) {
      return nav.pop();
    }
  }

  renderScene(route, nav) {
    switch (route.id) {
      case 'hashtag':
        return <HashtagListView
          style={{ flex: 1 }} 
          navigator={nav}
          ddp={this.props.ddp}
          category={route.category} />;
      case 'servicelink':
        return <WebView
          style={styles.webView}
          onNavigationStateChange={(navState) => this._onNavigationStateChange(nav, navState)}
          startInLoadingState={true}
          url={route.link} />;
      case 'editprofile':
        return <MeEdit navigator={nav}
          ddp={this.props.ddp} 
          me={this.props.me}
          integrations={this.props.integrations} />
      case 'viewprofile':
        return <Activities navigator={nav} 
          me={route.me}
          activities={this.props.myActivities}
          ddp={this.props.ddp} />
      default:
        return (
          <Me me={this.props.me} 
            categories={this.props.categories}
            myTags={this.props.myTags}
            navigator={nav}
            ddp={this.props.ddp} />
        );
    }
  }

  render() {
    return (
      <Navigator
        itemWrapperStyle={styles.navWrap}
        style={styles.nav}
        renderScene={this.renderScene.bind(this)}
        configureScene={(route) =>
          Navigator.SceneConfigs.HorizontalSwipeJump}
        initialRoute={{
          title: 'Me',
        }}
        navigationBar={
          <Navigator.NavigationBar
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
    marginTop: 64,
    paddingTop: 64,
  },
  nav: {
    flex: 1,
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


module.exports = MeNavigator;