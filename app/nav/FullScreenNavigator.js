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
      onEditProfileChange: this.onEditProfileChange.bind(this),
      onEditProfileFocus: this.onEditProfileFocus.bind(this),
      onEditProfileBlur: this.onEditProfileBlur.bind(this),
      updateProfile: this.updateProfile.bind(this),
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
              Router.instance.getProfileRoute({ userId: properties.args.userId }));
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

  onEditProfileChange(activeText) {
    logger.debug('onEditProfileChange')
    Router.instance.currentlyEditing = activeText;
  }

  onEditProfileFocus(key) {
    logger.debug('onEditProfileFocus')
    Router.instance.editProfileFocused = true;
    Router.instance.editProfileKey = key;
  }

  onEditProfileBlur() {
    logger.debug('onEditProfileBlur')
    Router.instance.editProfileFocus = false;
  }

  updateProfile(key, value) {
    // TODO(qimingfang)
    logger.debug('updateProfile')

    let myInfo = {};
    myInfo[key] = value;
    return this.props.ddp.call({ methodName: 'me/update', params: [myInfo] })
    .catch(err => {
      logger.error(err);
      AlertIOS.alert('Missing Some Info!', err.reason);
    })
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
