import React, {
  Navigator,
  TouchableOpacity,
  Text,
  StyleSheet,
} from 'react-native';

// external dependencies
import { connect } from 'react-redux/native';

import OnboardingRouter from './OnboardingRouter';
import LoginScreen from '../components/onboarding/LoginScreen';
import TSNavigationBar from '../components/lib/TSNavigationBar';

const logger = new (require('../../modules/Logger'))('OnboardingNavigator');

function mapStateToProps(state) {
  return {
    loggedIn: state.loggedIn,
    isCWLRequired: state.isCWLRequired,
    currentScreen: state.currentScreen,
    nav: state.routes.onboarding.nav,
  }
}

class OnboardingNavigator extends React.Component {

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

  renderScene(route, nav) {
    this.router = this.router || new OnboardingRouter(nav, this.props.dispatch);
    const props = Object.assign({}, this.props, route.props);

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
          props: Object.assign({}, this.props, {
            toSceneAfterLogin: this.toSceneAfterLogin.bind(this)
          }),
        }}
        navigationBar={
          <TSNavigationBar
            hidden={this.props.nav.hidden}
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
