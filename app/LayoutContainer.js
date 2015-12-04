import React, {
  StyleSheet,
  Component,
  View,
  Text,
  TouchableOpacity
} from 'react-native';

// TODO(qimingfang): remove dependencies on these native modules directly.
let TSLayerService = React.NativeModules.TSLayerService;

// external dependencies
import { connect } from 'react-redux/native';
import { FBSDKLoginManager } from 'react-native-fbsdklogin';

// internal dependencies
import RootNavigator from './RootNavigator';
import OnboardingNavigator from './OnboardingNavigator';
import Session from '../native_modules/Session';
import Intercom from '../modules/Intercom';
import ResumeTokenHandler from './util/ResumeTokenHandler'

const logger = new (require('../modules/Logger'))('LayoutContainer');

class LayoutContainer extends React.Component {

  constructor(props = {}) {
    super(props);
    this.resumeTokenHandler = new ResumeTokenHandler(props.ddp, Session);
  }

  componentWillMount() {
    this.props.ddp.initialize()
    .then(() => {
      return this.resumeTokenHandler.handle(this.props.dispatch)
    })
    .then((loginResult) => {
      this._onUserHasLoggedIn();
    })
    .catch(err => {
      switch(err) {
        case this.resumeTokenHandler.errors.COULD_NOT_LOG_IN:
          break;
        default:
          logger.error(err);
      }
    })
  }

  _setupLayer() {
    const ERRORS = {
      LAYER_ALREADY_LOGGED_IN: 'LAYER_ALREADY_LOGGED_IN',
    }

    return TSLayerService.connectAsync()
    .then(() => {
      return TSLayerService.isAuthenticatedAsync();
    })
    .then((isAuthenticated) => {
      if (isAuthenticated) {
        return Promise.reject(ERRORS.LAYER_ALREADY_LOGGED_IN);
      }
      return TSLayerService.requestAuthenticationNonceAsync()
    })
    .then((nonce) => {
      return this.props.ddp.call({ methodName: 'layer/auth', params: [nonce]});
    })
    .then((sessionId) => {
      return TSLayerService.authenticateAsync(sessionId)
    })
    .catch(err => {
      switch (err) {
        case ERRORS.LAYER_ALREADY_LOGGED_IN:
          return;
        default:
          logger.error(err);
      }
    })
  }

  _setupIntercom() {
    this.ddp.call({ methodName: 'intercom/auth' })
    .then(({ hash, identifier }) => {
      Intercom.setHMAC(hash, identifier);
    });
  }

  /**
   * Common to all login scenarios (resume, fb, digits)
   */
  _onUserHasLoggedIn() {
    // subscribe to the user specific endpoints
    this.props.ddp.subscribe();

    // set up 3p integrations
    this._setupLayer();
    this._setupIntercom();
  }

  onPressLogout() {
    this.props.dispatch({
      type: 'LOGOUT'
    })

    Session.logout();
    FBSDKLoginManager.logOut();

    this.props.ddp.logout()
  }

  onPressLogin({ id, token, tokenExpires}) {
    logger.debug(`Pressed Login. userId=${id}`)

    const expiryDate = tokenExpires.getTime();
    Session.login(id, token, expiryDate);
  }

  render() {
    logger.debug(`Rendering layout. loggedIn=${this.props.loggedIn}`)

    if (!this.props.loggedIn) {
      return (
        <OnboardingNavigator
          style={{ flex: 1 }}
          sceneStyle={{ paddingTop: 64 }}
          onPressLogout={this.onPressLogout.bind(this)}
          onPressLogin={this.onPressLogin.bind(this)}
        />
      )
    }

    return (
      <RootNavigator
        style={{ flex: 1 }}
        sceneStyle={{ paddingTop: 64 }}
        onPressLogout={this.onPressLogout.bind(this)}
      />
    )
  }
}

function mapStateToProps(state) {
  return {
    ddp: state.ddp,
    loggedIn: state.loggedIn,
  }
}

export default connect(mapStateToProps)(LayoutContainer)
