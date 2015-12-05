import React, {
  Navigator,
  TouchableOpacity,
  Text,
  NativeAppEventEmitter,
  StyleSheet,
} from 'react-native';

// external dependencies
import { connect } from 'react-redux/native'

import TSNavigationBar from './components/lib/TSNavigationBar';
import Router from './Router';
import RootNavigator from './RootNavigator';
import { COLORS, SHEET } from './CommonStyles'

const logger = new (require('../modules/Logger'))('FullScreenNavigator');

function mapStateToProps(state) {
  return {
    currentScreen: state.currentScreen,
    nav: state.routes.fullscreen.nav,
    displayTitle: state.routes.fullscreen.nav.displayTitle
  }
}

class FullScreenNavigator extends React.Component {

  leftButton(route, navigator, index, navState) {
    return null;
  }

  rightButton(route, navigator, index, navState) {
    return null;
  }

  title(route) {
    return null;
  }

  componentDidMount() {
    this.navigateToConversationViewListener = NativeAppEventEmitter
      .addListener('Navigation.push', (properties) => {
        logger.debug(`did receive Navigation.push. Properties=${JSON.stringify(properties)}`)
        switch (properties.routeId) {
          case 'conversation':
            return this.router.toConversation({
              conversationId: properties.args.conversationId
            })

          case 'profile':
            return this.router.toProfile({
              userId: properties.args.userId
            })
        }
    });

    this.popListener = NativeAppEventEmitter
      .addListener('Navigation.pop', (properties) => {
        logger.debug('did receive Navigation.pop')
        this.router.pop();
      });
  }

  renderScene(route, nav) {
    logger.debug(`renderscene with currentScreen=${JSON.stringify(this.props.currentScreen)}`)
    this.router = this.router || new Router(nav, this.props.dispatch)

    if (this.router.canHandleRoute(this.props.currentScreen.present)) {
      return this.router.handle(this.props.currentScreen.present);
    }

    return <RootNavigator {...route.props} />
  }

  render() {
    logger.debug(`rendering full screen nav. hidden=${JSON.stringify(this.props.nav.hidden)}`);

    return (
      <Navigator
        ref='nav'
        style={styles.nav}
        itemWrapperStyle={styles.nav}
        renderScene={this.renderScene.bind(this)}
        configureScene={(route) => ({
          ...Navigator.SceneConfigs.HorizontalSwipeJump,
          gestures: {}, // or null
        })}
        initialRoute={{
          id: this.props.currentScreen.present.id,
          props: this.props,
        }}
        navigationBar={
          <TSNavigationBar
            hidden={this.props.nav.hidden}
            routeMapper={{
              LeftButton: this.leftButton.bind(this),
              RightButton: this.rightButton.bind(this),
              Title: this.title.bind(this)
            }}
          />
        }>
      </Navigator>
    )
  }
}

let styles = StyleSheet.create({
  nav: {
    flex: 1,
  },
  navBarTitleText: {
    fontSize: 20,
    color:  'black',
    fontWeight: '500',
    marginVertical: 9,
  },
  selected: {
    tintColor: '#64369C',
  },
  selectedText: {
    color: '#64369C',
  }
});

export default connect(mapStateToProps)(FullScreenNavigator)
