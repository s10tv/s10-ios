import ExNavigator from '@exponent/react-native-navigator';

import React, {
  AlertIOS,
  NativeAppEventEmitter,
  StyleSheet,
} from 'react-native';

// external dependencies
import { connect } from 'react-redux/native'

import Router from './Routes';
import { SHEET } from '../CommonStyles'
import Analytics from '../../modules/Analytics';

const logger = new (require('../../modules/Logger'))('FullScreenNavigator');

function mapStateToProps(state) {
  return {
    ddp: state.ddp,
    loggedIn: state.loggedIn,
    isActive: state.isActive,
    hasLoggedInThroughCWL: state.hasLoggedInThroughCWL,
    currentScreen: state.currentScreen,
  }
}

class FullScreenNavigator extends React.Component {

  constructor(props = {}) {
    super(props);

    const amendedProps = Object.assign({}, props, {
      reportUser: this.reportUser.bind(this),
    });

    Router.instance = new Router(amendedProps);
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
              Router.instance.getProfileRoute({
                userId: properties.args.userId,
                isFromConversationScreen: true,
              }));
            break;
        }
    });

    this.popListener = NativeAppEventEmitter
      .addListener('Navigation.pop', (properties) => {
        logger.debug('did receive Navigation.pop')
        this.refs['fullScreenNav'].pop();
      });

    this.reportUserListener = NativeAppEventEmitter
      .addListener('Profile.showMoreOptions', (userId) => {
        logger.debug('did receive Profile.showMoreOption');
        this.reportUser(userId);
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

  resetRouteStackToLogin() {
    const route = Router.instance.getLoginRoute();
    const navigator = this.refs['fullScreenNav'];
    if (navigator) {
      navigator.immediatelyResetRouteStack([route])
    }
  }

  resetRotueStackToMain() {
    const route = Router.instance.getMainNavigatorRoute()
    const navigator = this.refs['fullScreenNav'];
    if (navigator) {
      navigator.immediatelyResetRouteStack([route])
    }
  }

  reportUser(userId) {
    if (!userId) {
      logger.warning(`tring to report user with invalid userid`);
      return;
    }

    const user = this.props.ddp.collections.users.findOne({ _id: userId });
    if (!user) {
      logger.warning(`tring to report user with invalid userid=${userId}`);
      return;
    }

    AlertIOS.alert(
      `Report ${user.firstName}?`,
      "",
      [
        {text: 'Cancel', onPress: () => null },
        {text: 'Report', onPress: () => {
          return this.props.ddp.call({ methodName: 'user/report', params: [userId, 'Reported'] })
          .then(() => {
            Analytics.track("User: Confirmed Block")
            AlertIOS.alert(`Reported ${user.firstName}`,
              'Thanks for your input. We will look into this shortly.');
          })
          .catch(err => {
            logger.error(err);
          })
        }},
      ]
    )
  }

  render() {
    logger.debug(`isLoggedIn=${this.props.loggedIn} isActive=${this.props.isActive}`)

    // TODO(qimingfang): This is probably not good practice since it introduces
    // side effects. However, I dont see any easy way of synchronizing the router's
    // current state with that of redux (without wiring router into redux).
    Router.instance.currentScreen = this.props.currentScreen;
    Router.instance.hasLoggedInThroughCWL = this.props.hasLoggedInThroughCWL;

    let route;
    if (this.props.loggedIn && this.props.isActive) {
      route = Router.instance.getMainNavigatorRoute()
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
