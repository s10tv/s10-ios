let React = require('react-native');
var Button = require('react-native-button');

let {
  AppRegistry,
  Navigator,
  Text,
  TouchableOpacity,
  WebView,
  Image,
  View,
  StyleSheet,
  NativeAppEventEmitter,
} = React;

var { TabBarIOS, } = require('react-native-icons');

// Common
let BaseTaylrNavigator = require('./lib/BaseTaylrNavigator');
let SHEET = require('./CommonStyles').SHEET;
let COLORS = require('./CommonStyles').COLORS;
let Loader = require('./lib/Loader');

// Me
let MeScreen = require('./me/MeScreen');
let MeEditScreen = require('./me/MeEditScreen');

// Discover
let DiscoverScreen = require('./discover/DiscoverScreen');

// Chats
let ConversationView = require('./chat/ConversationView');
let ConversationListView = require('./chat/ConversationListView');

// Supporting
let Activities = require('./lib/Activities');

// Libraries
let HashtagListView = require('./lib/HashtagListView');
let TSNavigationBar = require('./lib/TSNavigationBar');


class RootNavigator extends BaseTaylrNavigator {

  constructor(props) {
    super(props);
    this.state = {
      currentTab: 'me'
    }
  }

  componentWillMount() {
    this.setState({
      popListener: NativeAppEventEmitter.addListener('Navigation.pop', (properties) => {
        this.refs['nav'].pop()
      }.bind(this)),
      pushListener: NativeAppEventEmitter.addListener('Navigation.push', (properties) => {
        switch (properties.routeId) {
          case 'conversation':
            this.refs['nav'].push({
              id: 'conversation',
              conversationId: properties.args.conversationId,
            })
            break;
          case 'profile':
            // TODO: Implement me correctly
            // this.push({
            //   id: 'viewprofile',
            //   conversationId: properties.args.conversationId,
            // })
            break;
        }
      }.bind(this))
    });
  }

  componentWillUnmount() {
    this.state.popListener.remove();
    this.state.pushListener.remove();
    this.setState({
      popListener: null,
      pushListener: null
    });
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
    let me = this.props.me;

    if (!me) {
      return <Loader />
    }

    let user = {
      userId: me._id,
      firstName: me.firstName,
      lastName: me.lastName,
      avatarUrl: me.avatar.url,
      coverUrl: 'https://s10tv.blob.core.windows.net/s10tv-prod/defaultbg.jpg',
      displayName: `${me.firstName} ${me.lastName}`,
    }

    switch (route.id) {
      case 'edit':
        return <MeEditScreen navigator={nav}
          ddp={this.props.ddp} 
          me={this.props.me}
          integrations={this.props.integrations} />
      
      case 'addhashtag':
        return <HashtagListView
          style={{ flex: 1 }} 
          navigator={nav}
          ddp={this.props.ddp}
          myTags={this.props.myTags}
          category={route.category} />;
      
      case 'linkservice':
        return <WebView
          style={styles.webView}
          onNavigationStateChange={(navState) => this._onNavigationStateChange(nav, navState)}
          startInLoadingState={true}
          url={route.link} />;
      
      case 'viewprofile':
        return <Activities
          navigator={nav} 
          me={route.me}
          loadActivities={true}
          ddp={this.props.ddp} />
      
      case 'openwebview':
        return <WebView
          style={styles.webView}
          startInLoadingState={true}
          url={route.url} />;

      case 'sendMessage':
        return <ConversationView 
          navigator={nav}
          style={{flex: 1}}
          recipientId={route.recipientId}
          currentUser={user} />

      case 'conversation':
        return <ConversationView
          navigator={nav}
          style={{flex: 1}}
          conversationId={route.conversationId}
          currentUser={user} />

      case 'root':
        console.log('root');
        console.log(this.state.currentTab);
        return (
          <TabBarIOS tintColor={COLORS.taylr}>
            <TabBarIOS.Item 
              title="Me"
              iconName={'ion|ios-person'}
              onPress={() => {
                this.setState({currentTab: 'me'});
              }}
              selected={this.state.currentTab == 'me'}>
              
              <MeScreen me={this.props.me} 
                onLogout={this.props.onLogout}
                categories={this.props.categories}
                myTags={this.props.myTags}
                navigator={nav}
                ddp={this.props.ddp} />

            </TabBarIOS.Item>
            <TabBarIOS.Item 
              title="Discover"
              iconName={'ion|compass'}
              onPress={() => {
                this.setState({currentTab: 'discover'});
              }}
              selected={this.state.currentTab == 'discover'}>

              <DiscoverScreen navigator={nav} ddp={this.ddp} 
                candidate={this.props.candidate}
                users={this.props.users}
                settings={this.props.settings} />

            </TabBarIOS.Item>
            <TabBarIOS.Item 
              title="Chats"
              iconName={'ion|chatbubbles'}
              onPress={() => {
                this.setState({currentTab: 'chats'});
              }}
              selected={this.state.currentTab == 'chats'}>
              
              <ConversationListView
                navigator={nav}
                style={{backgroundColor: COLORS.background, flex: 1, marginTop: 64}}
                currentUser={user} />
                
            </TabBarIOS.Item>
          </TabBarIOS>
          
        );
    }
  }

  render() {
    return (
      <Navigator
        ref='nav'
        itemWrapperStyle={styles.navWrap}
        style={styles.nav}
        renderScene={this.renderScene.bind(this)}
        configureScene={(route) => ({
          ...Navigator.SceneConfigs.HorizontalSwipeJump,
          gestures: {}, // or null
        })}
        initialRoute={{
          id: 'root',
          title: 'Taylr',
        }}
        navigationBar={
          <TSNavigationBar
            ref='navbar'
            omitRoutes={['conversation']}
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

let styles = StyleSheet.create({
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

module.exports = RootNavigator;