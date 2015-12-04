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
import FullScreenNavigator from './FullScreenNavigator';
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

  /**
   * Common to all login scenarios (resume, fb, digits)
   */
  _onUserHasLoggedIn() {
    logger.debug('will execute _onUserHasLoggedIn');

    // subscribe to the user specific endpoints
    this.props.ddp.resubscribe(this.props.dispatch);

    // set up 3p integrations
    this._setupLayer();
    this._setupIntercom();
  }

  _setupLayer() {
    const ERRORS = {
      LAYER_ALREADY_CONNECTING: 'LAYER_ALREADY_CONNECTING',
      LAYER_ALREADY_LOGGED_IN: 'LAYER_ALREADY_LOGGED_IN',
    }

    const connectPromise = TSLayerService.connectAsync()
    .catch(err => {
      switch (err.code) {
        case 6000:
          return Promise.reject(ERRORS.LAYER_ALREADY_CONNECTING);
        default:
          return Promise.reject(err);
      }
    })

    return connectPromise
    .then(() => {
      return TSLayerService.isAuthenticatedAsync();
    })
    .then((isAuthenticated) => {
      logger.debug(`Is layer already authenticated? ${isAuthenticated}`)
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
        case ERRORS.LAYER_ALREADY_CONNECTING:
        case ERRORS.LAYER_ALREADY_LOGGED_IN:
          return;
        default:
          logger.error(err);
      }
    })
  }

  _setupIntercom() {
    this.props.ddp.call({ methodName: 'intercom/auth' })
    .then(({ hash, identifier }) => {
      Intercom.setHMAC(hash, identifier);
    });
  }

  onPressLogout() {
    TSLayerService.deauthenticateAsync() // TODO(qimingfang): this can throw if already connected.
    .catch(err => {
      logger.warning(err);
    });

    this.props.ddp.logout()

    Session.logout();
    FBSDKLoginManager.logOut();

    this.props.dispatch({
      type: 'LOGOUT'
    })
  }

  onPressLogin({ userId, resumeToken, expiryDate}) {
    logger.debug('Will call onPressLogin');

    // persist user sesison to disk
    Session.login(userId, resumeToken, expiryDate);

    // trigger common onLogin actions.
    this._onUserHasLoggedIn()
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
      <FullScreenNavigator
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
