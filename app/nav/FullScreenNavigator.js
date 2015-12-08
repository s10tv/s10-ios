import ExNavigator from '@exponent/react-native-navigator';

import React, {
  NativeAppEventEmitter,
  StyleSheet,
} from 'react-native';

// external dependencies
import { connect } from 'react-redux/native'

import Router from './Routes';
import { SHEET } from '../CommonStyles'

const logger = new (require('../../modules/Logger'))('FullScreenNavigator');

function mapStateToProps(state) {
  return {
    loggedIn: state.loggedIn,
    isActive: state.isActive,
    currentScreen: state.currentScreen,
  }
}

class FullScreenNavigator extends React.Component {

  constructor(props = {}) {
    super(props);
    Router.instance = new Router(props);
  }

  componentWillMount() {
    this.navigateToConversationViewListener = NativeAppEventEmitter
      .addListener('Navigation.push', (properties) => {
        logger.debug(`did receive Navigation.push. Properties=${JSON.stringify(properties)}`)
        switch (properties.routeId) {
          case 'conversation':
            this.refs['fullScreenNav'].push(
              Router.instance.getConverstionRoute(properties.args.conversationId))
            break;

          case 'profile':
            this.refs['fullScreenNav'].push(
              Router.instance.getProfileRoute(properties.args.userId));
            break;
        }
    });

    this.popListener = NativeAppEventEmitter
      .addListener('Navigation.pop', (properties) => {
        logger.debug('did receive Navigation.pop')
        this.refs['fullScreenNav'].pop();
      });
  }

  componentWillUnmount() {
    if (this.navigateToConversationViewListener) {
      this.navigateToConversationViewListener.remove();
    }

    if (this.popListener) {
      this.popListener.remove();
    }
  }

  render() {
    // TODO(qimingfang): This is probably not good practice since it introduces
    // side effects. However, I dont see any easy way of synchronizing the router's
    // current state with that of redux (without wiring router into redux).
    Router.instance.currentScreen = this.props.currentScreen;

    let route;
    if (this.props.loggedIn && this.props.isActive) {
      route = Router.instance.getMainNavigatorRoute(this.props.currentScreen)
    } else {
      route = Router.instance.getLoginRoute();
    }

    return (
      <ExNavigator
        ref="fullScreenNav"
        showNavigationBar={false}
        initialRoute={route}
      />
    );
  }
}

let styles = StyleSheet.create({
});

export default connect(mapStateToProps)(FullScreenNavigator)
