let React = require('react-native');
var Button = require('react-native-button');

let {
  AppRegistry,
  View,
  Text,
  Image,
  TouchableOpacity,
  Navigator,
  NavigatorIOS,
  TabBarIOS,
  WebView,
  StyleSheet,
} = React;

let commonStyles = require('./CommonStyles')
let ddp = require('../lib/ddp');
let Me = require('./Me');
let MeEdit = require('./MeEdit');
let Activities = require('./Activities');
let HashtagCategory = require('./HashtagCategory');
let HashtagListView = require('./HashtagListView');
let Discover = require('./Discover');
let SHEET = require('./CommonStyles').SHEET;
let ContainerView = require('./ContainerView');

class LayoutContainer extends React.Component {

  constructor(props: {}) {
    super(props);
    this.state = {
      modalVisible: false,
      currentTab: 'discover',
    }
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

  _title (route, navigator, index, navState) {
    return (
      <Text style={[styles.navBarText, styles.navBarTitleText, SHEET.baseText]}>
        {route.title}
      </Text>
    );
  }

  _onNavigationStateChange(nav, navState) {
    console.log(navState.url);
    if (navState.url.indexOf('taylr-dev://') != -1) {
      return nav.pop();
    }
  }

  renderScene(route, nav) {
    switch (route.id) {
      case 'hashtag':
        return <HashtagListView style={{ flex: 1 }} navigator={nav} category={route.category} />;
      case 'servicelink':
        return <WebView
          style={styles.webView}
          onNavigationStateChange={(navState) => this._onNavigationStateChange(nav, navState)}
          startInLoadingState={true}
          url={route.link} />;
      case 'editprofile':
        return <MeEdit navigator={nav} me={route.me} integrations={route.integrations} />
      case 'viewprofile':
        console.log(route.me);
        return <Activities navigator={nav} me={route.me} />
      default:
        return (
          <Me navigator={nav} />
        );
    }
  }

  renderDiscoverScene(route, nav) {
    switch (route.id) {
      case 'viewprofile':
        return <Activities navigator={nav} me={route.me} />
      case 'sendMessage':
        return <ContainerView sbName="Conversation" />
      default:
        return (
          <Discover navigator={nav} />
        );
    } 
  }

  render() {
    return (
      <TabBarIOS>
        <TabBarIOS.Item 
          title="Me"
          onPress={() => {
            this.setState({currentTab: 'me'});
          }}
          selected={this.state.currentTab == 'me'}>
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
        </TabBarIOS.Item>
        <TabBarIOS.Item 
          title="Discover"
          onPress={() => {
            this.setState({currentTab: 'discover'});
          }}
          selected={this.state.currentTab == 'discover'}>

          <Navigator
            itemWrapperStyle={styles.navWrap}
            style={styles.nav}
            renderScene={this.renderDiscoverScene.bind(this)}
            configureScene={(route) =>
              Navigator.SceneConfigs.HorizontalSwipeJump}
            initialRoute={{
              title: 'Discover',
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
        </TabBarIOS.Item>
        <TabBarIOS.Item 
          title="Chats"
          onPress={() => {
            this.setState({currentTab: 'chats'});
          }}
          selected={this.state.currentTab == 'chats'}>
            <View />
        </TabBarIOS.Item>
      </TabBarIOS>
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

module.exports = LayoutContainer;