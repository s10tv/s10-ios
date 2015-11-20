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
let COLORS = require('../CommonStyles').COLORS;
let BaseTaylrNavigator = require('../lib/BaseTaylrNavigator');
let Activities = require('../lib/Activities');
let Loader = require('../lib/Loader');
let TSNavigationBar = require('../lib/TSNavigationBar');
let ConversationView = require('../../ios/Taylr/NativeModules/ConversationView/ConversationView');
let ConversationListView = require('../../ios/Taylr/NativeModules/ConversationListView/ConversationListView');

class ChatNavigator extends BaseTaylrNavigator {
  _leftButton(route, navigator, index, navState) {
    return null
  }

  _rightButton(route, navigator, index, navState) {
    return null;
  }

  renderScene(route, nav) {
    let me = this.props.me;
    let user = {
      userId: me._id,
      firstName: me.firstName,
      lastName: me.lastName,
      avatarUrl: me.avatar.url,
      coverUrl: 'https://s10tv.blob.core.windows.net/s10tv-prod/defaultbg.jpg',
      displayName: `${me.firstName} ${me.lastName}`,
    }
    console.log('xxxxxxx', route.id);
    switch (route.id) {
      case 'conversationlist':
        return <ConversationListView
          navigator={nav}
          style={{backgroundColor: COLORS.background, flex: 1, marginTop: 64}}
          currentUser={user} />

      case 'conversation':
        return <ConversationView
          navigator={nav}
          style={{flex: 1}}
          conversationId={route.conversationId}
          currentUser={user} />
    }
  }

  render() {
    let me = this.props.me;
    if (!me) {
      return <Loader />
    }

    return (
      <Navigator
        itemWrapperStyle={styles.navWrap}
        style={styles.nav}
        renderScene={this.renderScene.bind(this)}
        configureScene={(route) => ({
          ...Navigator.SceneConfigs.HorizontalSwipeJump,
          gestures: {}, // or null
        })}
        initialRoute={{
          id: 'conversationlist',
          title: 'Chat',
        }}
        navigationBar={
          <TSNavigationBar
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

var styles = StyleSheet.create({
  navWrap: {
    flex: 1,
  },
  nav: {
    flex: 1,
  },
  navBar: {
    backgroundColor: '#64369C',
  }
});

module.exports = ChatNavigator;