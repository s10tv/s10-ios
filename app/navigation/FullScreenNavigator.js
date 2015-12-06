import React, {
  Navigator,
  NativeAppEventEmitter,
  StyleSheet,
} from 'react-native';

// external dependencies
import { connect } from 'react-redux/native'

// internal depdencies
import FullScreenRouter from './FullScreenRouter';
import RootNavigator from './RootNavigator';
import { COLORS, SHEET } from '../CommonStyles'
import TSNavigationBar from '../components/lib/TSNavigationBar';
import BridgeManager from '../../modules/BridgeManager';

const logger = new (require('../../modules/Logger'))('FullScreenNavigator');

function mapStateToProps(state) {
  return {
    currentScreen: state.currentScreen,
    nav: state.routes.fullscreen.nav,
    displayTitle: state.routes.fullscreen.nav.displayTitle,
  }
}

class FullScreenNavigator extends React.Component {

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

  onViewProfile(userId) {
    return this.router.toProfile({ userId });
  }

  /**
   * Determines when to close the service link card.
   */
  _onServiceLinkNavStateChange(navState) {
    if (navState.url.indexOf(BridgeManager.bundleUrlScheme()) != -1) {
      this.router.pop()
    }
  }

  /**
   * When a user clicks on a card to link a service .
   */
  onLinkViaWebView(url) {
    return this.router.toLinkWebView({
      onServiceLinkNavStateChange: this._onServiceLinkNavStateChange.bind(this),
      url
    });
  }

  leftButton(route, navigator, index, navState) {
    this.router = this.router || new FullScreenRouter(nav, this.props.dispatch)
    return this.router.leftButton(this.props.currentScreen.present);
  }

  rightButton(route, navigator, index, navState) {
    this.router = this.router || new FullScreenRouter(nav, this.props.dispatch)
    return this.router.rightButton(this.props.currentScreen.present);
  }

  title(route) {
    return this.router.title(this.props.currentScreen.present);
  }

  renderScene(route, nav) {
    this.router = this.router || new FullScreenRouter(nav, this.props.dispatch)

    if (this.router.canHandleRoute(this.props.currentScreen.present)) {
      return this.router.handle(this.props.currentScreen.present,
        Object.assign({}, this.props, route.props));
    }

    return <RootNavigator {...route.props} />
  }

  render() {
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
          props: Object.assign({}, this.props, {
            onViewProfile: this.onViewProfile.bind(this),
            onLinkViaWebView: this.onLinkViaWebView.bind(this),
          })
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
