let React = require('react-native');
var Button = require('react-native-button');

let {
  AppRegistry,
  Navigator,
  Text,
  TouchableOpacity,
  StyleSheet,
} = React;

let BaseTaylrNavigator = require('../lib/BaseTaylrNavigator');
let SHEET = require('../CommonStyles').SHEET;
let Me = require('./Me');
let MeEdit = require('./MeEdit');
let Activities = require('../lib/Activities');
let HashtagListView =require('../lib/HashtagListView');

class MeNavigator extends BaseTaylrNavigator {
  constructor(props) {
    super(props);
    this.ddp = props.ddp;
  }

  _leftButton(route, navigator, index, navState) {
    if (route.id) {
      return (
        <TouchableOpacity
          onPress={() => navigator.pop()}
          style={SHEET.navBarLeftButton}>
          <Text style={[SHEET.navBarText, SHEET.navBarButtonText, SHEET.baseText]}>
            Back
          </Text>
        </TouchableOpacity>
      );
    }
  }

  _rightButton(route, navigator, index, navState) {
    return null;
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
});


module.exports = MeNavigator;