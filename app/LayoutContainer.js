import React, {
  StyleSheet,
  Component,
  View,
  Text,
  NativeModules,
  TouchableOpacity
} from 'react-native';

// TODO(qimingfang): remove dependencies on these native modules directly.
let TSLayerService = React.NativeModules.TSLayerService;

// external dependencies
import { connect } from 'react-redux/native';
import { FBSDKLoginManager } from 'react-native-fbsdklogin';

// internal dependencies
import FullScreenNavigator from './navigation/FullScreenNavigator';
import OnboardingNavigator from './navigation/OnboardingNavigator';
import Session from '../native_modules/Session';
import Intercom from '../modules/Intercom';
import ResumeTokenHandler from './util/ResumeTokenHandler'

const logger = new (require('../modules/Logger'))('LayoutContainer');
const UIImagePickerManager = NativeModules.UIImagePickerManager;
const TSAzureClient = NativeModules.TSAzureClient;

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

  onUploadImage({
      type,
      dimensions = { width: 640, height: 480},
      contentType = 'image/jpeg' })  {

    logger.info('onUploadImage pressed');

    const UPLOAD_ERRORS = {
      ERROR_UPLOAD_CANCELLED: 'ERROR_UPLOAD_CANCELLED'
    };

    switch (type) {
      case 'PROFILE_PIC': // fallthrough intentional
      case 'COVER_PIC':
        let taskId =  'task_' + Math.floor(Math.random() * (10000000000 - 10000)) + 10000;
        return new Promise((resolve, reject) => {
          var options = {
            title: 'Select', // specify null or empty string to remove the title
            cancelButtonTitle: 'Cancel',
            takePhotoButtonTitle: 'Take Photo...',
            chooseFromLibraryButtonTitle: 'Choose from Library...',
            quality: 1,
            maxWidth: dimensions.width || 640,
            maxHeight: dimensions.height || 480,
            allowsEditing: false, // Built in iOS functionality to resize/reposition the image
            noData: false, // Disables the base64 `data` field from being generated (greatly improves performance on large photos)
          }

          UIImagePickerManager.showImagePicker(options, (didCancel, response) => {
            if (didCancel) {
              return reject(UPLOAD_ERRORS.ERROR_UPLOAD_CANCELLED);
            }
            return resolve(response);
          })
        })
        .then((response) => {
          const localFileURI = response.uri.replace('file://', '');

          this.props.dispatch({
            type: 'UPLOAD_START',
            taskId: taskId,
            type: type,
          });

          return this.props.ddp.call({
            methodName: 'startTask',
            params:[taskId, type, {
              width: width,
              height: height,
            }]
          })
        })
        .then(({ azureUrl }) => {
          return AzureClient.putAsync(azureUrl, localFileURI, contentType);
        })
        .then(() => {
          return this.props.ddp.call({ methodName: 'finishTask', params: [taskId] });
        })
        .then(() => {
          this.props.dispatch({
            type: 'UPLOAD_FINISH'
          });
        })
        .catch(err => {
          switch (err) {
            case UPLOAD_ERRORS.ERROR_UPLOAD_CANCELLED:
              logger.info(`Cancelled image uploading type=${type}`);
              return;

            default:
              logger.warning(err);
              this.props.dispatch({
                type: 'UPLOAD_FINISH'
              });
              this.props.dispatch({
                type: 'DISPLAY_ERROR',
                title: 'Upload Error',
                message: 'There was a problem uploading your image',
              });
              return;
          }
        })


      default:
        const errMsg = `Called onUploadImage with invalid type=${type}`;
        logger.warning(errMsg);
        return Promise.reject(errMsg);
    }
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
          onUploadImage={this.onUploadImage.bind(this)}
        />
      )
    }

    return (
      <FullScreenNavigator
        style={{ flex: 1 }}
        sceneStyle={{ paddingTop: 64 }}
        onPressLogout={this.onPressLogout.bind(this)}
        onUploadImage={this.onUploadImage.bind(this)}
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
