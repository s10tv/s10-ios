import React, {
  Navigator,
  TouchableOpacity,
  Text,
  StyleSheet,
} from 'react-native';

// external dependencies
import { connect } from 'react-redux/native';
import CookieManager from 'react-native-cookies';

import OnboardingRouter from './OnboardingRouter';
import LoginScreen from '../components/onboarding/LoginScreen';
import TSNavigationBar from '../components/lib/TSNavigationBar';
import { SCREEN_OB_CWL_LOGIN } from '../constants';
import BridgeManager from '../../modules/BridgeManager';

const logger = new (require('../../modules/Logger'))('OnboardingNavigator');

function mapStateToProps(state) {
  return {
    loggedIn: state.loggedIn,
    isCWLRequired: state.isCWLRequired,
    currentScreen: state.currentScreen,
    nav: state.routes.onboarding.nav,
    hasLoggedInThroughCWL: state.hasLoggedInThroughCWL,
    ddp: state.ddp,
  }
}

class OnboardingNavigator extends React.Component {

  constructor(props = {}) {
    super(props);
    this.bindings = {
      toSceneAfterLogin: this.toSceneAfterLogin.bind(this),
      toCWLLoginScreen: this.toCWLLoginScreen.bind(this),
      onCWLLoginNavStateChange: this.onCWLLoginNavStateChange.bind(this),
      onLinkViaWebView: this.onLinkViaWebView.bind(this),
    }
  }

  leftButton(route, navigator, index, navState) {
    this.router = this.router || new OnboardingRouter(nav, this.props.dispatch);
    return this.router.leftButton(this.props.currentScreen.present);
  }

  rightButton(route, navigator, index, navState) {
    this.router = this.router || new OnboardingRouter(nav, this.props.dispatch);
    return this.router.rightButton(this.props.currentScreen.present);
  }

  title() {
    return this.router.title(this.props.currentScreen.present);
  }

  toSceneAfterLogin() {
    if (this.props.isCWLRequired) {
      return this.router.toJoinNetworkScreen();
    } else {
      return this.router.toLinkServiceScreen();
    }
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

  onCWLLoginNavStateChange(navState) {
    const cookieName = 'CASTGC';

    // We need to set timeout here, otherwise, we may end up in a situation where
    // the user is already logged in to CWL, but because the transition animation is too slow.
    //
    // Join network screen -> (push 1) -> CWL login -> (push 2) -> link service
    //
    // As a result, the screen could flicker to link service during (push 1).
    setTimeout(() => {
      if (!navState.loading && navState.title.length > 0) {
        logger.info('handling onCWLLoginNavStateChange');

        CookieManager.getAll((cookies, res) => {
          if (cookies && cookies[cookieName]) {
            this.props.dispatch({
              type: 'LOGGED_IN_THROUGH_CWL',
              loggedInThroughCWL: true,
            })

            this.props.ddp.call({
              methodName: 'network/join',
              params: [cookies[cookieName].value]
            });

            if (this.props.currentScreen.present.id == SCREEN_OB_CWL_LOGIN) {
              this.router.toLinkServiceScreen();
            }
          }
        })
      }
    }, 500);
  }

  toCWLLoginScreen() {
    return this.router.toCWLLoginScreen();
  }

  renderScene(route, nav) {
    this.router = this.router || new OnboardingRouter(nav, this.props.dispatch);
    const props = Object.assign({}, this.props, route.props, this.bindings);

    if (!this.props.loggedIn) {
      return <LoginScreen {...props} />
    }

    if (this.router.canHandleRoute(this.props.currentScreen.present)) {
      return this.router.handle(this.props.currentScreen.present, props);
    }

    return <LoginScreen {...props} />
  }

  render() {
    return (
      <Navigator
        ref='onboarding-nav'
        itemWrapperStyle={styles.nav}
        style={styles.nav}
        renderScene={this.renderScene.bind(this)}
        configureScene={(route) => ({
          ...Navigator.SceneConfigs.HorizontalSwipeJump,
          gestures: {}, // or null
        })}
        initialRoute={{
          id: 'not-used',
          props: Object.assign({}, this.props, this.bindings)
        }}
        navigationBar={
          <TSNavigationBar
            hidden={this.props.nav.hidden.present}
            routeMapper={{
              LeftButton: this.leftButton.bind(this),
              RightButton: this.rightButton.bind(this),
              Title: this.title.bind(this)
            }}
            style={styles.navBar}
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
  navBar: {
    backgroundColor: '#64369C',
  },
});

export default connect(mapStateToProps)(OnboardingNavigator);
