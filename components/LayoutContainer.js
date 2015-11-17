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
let TSDDPClient = require('../lib/ddpclient');
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
    this.ddp = new TSDDPClient();

    this.state = {
      modalVisible: false,
      currentTab: 'me',
    }
  }

  componentWillMount() {
    this.ddp.initialize('wss://s10-dev.herokuapp.com/websocket')
    .then(() => {
      return this.ddp.loginWithToken('_xkXDdHVfM5fj80ciYOC0kVFjEi6ObwHvRq9cdfIBlJ'); 
    }).then((res) => {
      this.setState(res);
    })
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
          ddp={this.ddp}
          category={route.category} />;
      case 'servicelink':
        return <WebView
          style={styles.webView}
          onNavigationStateChange={(navState) => this._onNavigationStateChange(nav, navState)}
          startInLoadingState={true}
          url={route.link} />;
      case 'editprofile':
        return <MeEdit navigator={nav} me={route.me} ddp={this.ddp} integrations={route.integrations} />
      case 'viewprofile':
        return <Activities navigator={nav} me={route.me} ddp={this.ddp} />
      default:
        return (
          <Me navigator={nav} ddp={this.ddp} />
        );
    }
  }

  renderDiscoverScene(route, nav) {
    switch (route.id) {
      case 'viewprofile':
        return <Activities navigator={nav} ddp={this.ddp} me={route.me} />
      case 'sendMessage':
        return <ContainerView sbName="Conversation" />
      default:
        return (
          <Discover navigator={nav} ddp={this.ddp} />
        );
    } 
  }

  render() {
    return (
      <TabBarIOS>
        <TabBarIOS.Item 
          title="Me"
          icon={require('./img/ic-me.png')}
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
          icon={require('./img/ic-compass.png')}
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
          icon={require('./img/ic-chats.png')}
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