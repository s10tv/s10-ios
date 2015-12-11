import React, {
  StyleSheet,
  Component,
  View,
  Text,
  NetInfo,
  LinkingIOS,
  AlertIOS,
  NativeModules,
  TouchableOpacity
} from 'react-native';

// TODO(qimingfang): remove dependencies on these native modules directly.
let TSLayerService = React.NativeModules.TSLayerService;

// external dependencies
import { connect } from 'react-redux/native';
import { FBSDKLoginManager } from 'react-native-fbsdklogin';
import { FBSDKAccessToken } from 'react-native-fbsdkcore';
import FechUBCClasses from 'ubc-classes';

// internal dependencies
import FullScreenNavigator from './nav/FullScreenNavigator';
import OverlayLoader from './components/lib/OverlayLoader';
import PopupDialog from './components/lib/PopupDialog';
import NetworkStatusOverlay from './components/lib/NetworkStatusOverlay';
import Session from '../native_modules/Session';
import Intercom from '../modules/Intercom';
import Analytics from '../modules/Analytics';
import BridgeManager from '../modules/BridgeManager';
import ResumeTokenHandler from './util/ResumeTokenHandler'

const logger = new (require('../modules/Logger'))('LayoutContainer');
const UIImagePickerManager = NativeModules.UIImagePickerManager;
const AzureClient = NativeModules.TSAzureClient;

function mapStateToProps(state) {
  return {
    ddp: state.ddp,
    showOverlayLoader: state.showOverlayLoader,
    dialog: state.dialog,
    isConnected: state.isConnected,
    shouldShowNetworkBanner: state.shouldShowNetworkBanner,
  }
}

class LayoutContainer extends React.Component {

  constructor(props = {}) {
    super(props);
    this.resumeTokenHandler = new ResumeTokenHandler(props.ddp, Session);
  }

  componentWillMount() {
    this._setupNetinfo()
    this._setupDDP()
  }

  _setupDDP() {
    this.props.ddp.initialize()
    .then(() => {
      // subscribe to settings before we log in
      return this.props.ddp.subscribeSettings(this.props.dispatch, false);
    })
    .then(() => {
      return this.resumeTokenHandler.handle(this.props.dispatch)
    })
    .then((result) => {
      const { intercomHash, userId } = result;
      Intercom.setHMAC(intercomHash, userId);

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

  _setupNetinfo() {
    NetInfo.isConnected.fetch().done((isConnected) => {
      this._handleConnectivityChange(isConnected);
    })

    NetInfo.isConnected.addEventListener('change', this._handleConnectivityChange.bind(this))
  }

  _handleConnectivityChange(isConnected) {
    logger.debug(`Network isConnected is now ${isConnected}`)

    // if we change from previously unconnected to internet to now connected
    if (!this.props.isConnected && isConnected) {
      logger.debug(`resubscribing as a result of regaining network`)

      // reconnect to DDP
      this._setupDDP()
    }

    this.props.dispatch({
      type: 'CHANGE_IS_CONNECTED',
      isConnected: isConnected,
    })
  }

  onPressLogout() {
    logger.debug('onPressLogout called');

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

    Analytics.userDidLogout();
  }

  onPressLogin({ userId, resumeToken, expiryDate, isNewUser }) {
    Analytics.userDidLogin(isNewUser);

    // Reset the tab bar to 'Today'
    this.props.dispatch({
      type: 'RESET_CURRENT_SCREEN'
    })

    // persist user sesison to disk
    Session.login(userId, resumeToken, expiryDate);

    // trigger common onLogin actions.
    this._onUserHasLoggedIn()
  }

  /**
   * Triggered whenever the user wants to upload a cover or avatar photo.
   */
  onUploadImage({
      type,
      dimensions = { width: 640, height: 480},
      contentType = 'image/jpeg' }) {

    logger.info('onUploadImage pressed');

    const UPLOAD_ERRORS = {
      ERROR_UPLOAD_CANCELLED: 'ERROR_UPLOAD_CANCELLED'
    };

    let localFileURI;

    switch (type) {
      case 'PROFILE_PIC': // fallthrough intentional
      case 'COVER_PIC':
        Analytics.track('Me: Update Image', {
          type: type
        });

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
            noData: true, // Disables the base64 `data` field from being generated (greatly improves performance on large photos)
          }

          UIImagePickerManager.showImagePicker(options, (didCancel, response) => {
            if (didCancel) {
              return reject(UPLOAD_ERRORS.ERROR_UPLOAD_CANCELLED);
            }
            return resolve(response);
          })
        })
        .then((response) => {
          localFileURI = response.uri.replace('file://', '');

          this.props.dispatch({
            type: 'UPLOAD_START',
            taskId: taskId,
          });

          return this.props.ddp.call({
            methodName: 'startTask',
            params:[taskId, type, {
              width: dimensions.width,
              height: dimensions.height,
            }]
          })
        })
        .then(({ url }) => {
          return AzureClient.putAsync(url, localFileURI, contentType);
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
              logger.error(err);
              this.props.dispatch({
                type: 'UPLOAD_FINISH'
              });
              this.props.dispatch({
                type: 'DISPLAY_ERROR',
                title: 'Upload Error',
                message: 'There was a problem uploading your image.',
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

  onFetchCourses() {
    fetch('https://courses.students.ubc.ca/cs/main?pname=regiregisteredcourses&tname=regiregisteredcourses', {
      credentials: 'include'
    })
    .then((response) => response.text())
    .then(responseText => {
      const courses = new FechUBCClasses().scrape(responseText);
      const promises = courses.map(course => {

        // dont insert courses that are not lectures.
        if (course.type !== 'Lecture') {
          return Promise.resolve()
        }

        return this.props.ddp.call({ methodName: 'courses/add', params: [course] });
      })

      if (promises.length == 0) {
        logger.warning(`NO classes were imported for userId=${this.props.ddp.currentUserId}`);
      }

      return Promise.all(promises);
    })
    .then(() => {
      AlertIOS.alert('Success', 'Your courses are now imported.');
    })
    .catch(err => {
      logger.error(err);
      this.props.dispatch({
        type: 'DISPLAY_ERROR',
        title: 'Importing Classes',
        message: 'There was a problem importing your classes :C Investigation is underway.',
      });
    })
  }

  onRemoveCourse(courseId) {
    this.props.ddp.call({ methodName: 'courses/remove', params: [courseId] })
    .catch(err => {
      logger.error(err);
      this.props.dispatch({
        type: 'DISPLAY_ERROR',
        title: 'Removing Course',
        message: 'There was a problem removing your course. :C Investigation is underway.',
      });
    })
  }

  /**
   * When a user clicks on a Facebook tile to link Facbeook, we want to leverage the FB SDK.
   */
  onLinkFacebook() {
    const RESPONSES = {
      CANCELLED_FB_LINK: 'CANCELLED_FB_LINK',
      ACCESS_TOKEN_INVALID: 'ACCESS_TOKEN_INVALID',
    };

    const displayFacebookError = () => {
      this.props.dispatch({
        type: 'DISPLAY_ERROR',
        title: 'Error linking Facebook',
        message: 'Hmm seems like we cannot link your Facebook at the moment.',
      });
    }

    // TODO: clean up duplicated code. This is ridiculous.
    // https://app.asana.com/0/34520227311296/69377281916556
    let permissions = ['email', 'public_profile', 'user_about_me',
    'user_birthday', 'user_education_history',
    'user_friends', 'user_location', 'user_photos', 'user_posts']

    return new Promise((resolve, reject) => {
      FBSDKLoginManager.logInWithReadPermissions(permissions, (error, result) => {
        if (error) {
          logger.error(error);
          displayFacebookError();
          return reject(error);
        }

        if (result.isCancelled) {
          return reject(RESPONSES.CANCELLED_FB_LINK);
        }

        return resolve(result);
      })
    })
    .then(() => {
      return new Promise((resolve, reject) => {
        FBSDKAccessToken.getCurrentAccessToken((accessToken) => {
          if (!accessToken || !accessToken.tokenString) {
            return reject(RESPONSES.ACCESS_TOKEN_INVALID)
          }
          return resolve(accessToken.tokenString);
        })
      })
    })
    .then((accessTokenString) => {
      return this.props.ddp.call({
        methodName: 'me/service/add',
        params: ['facebook', accessTokenString]
      })
    })
    .catch(err => {
      switch(err) {
        case RESPONSES.CANCELLED_FB_LINK:
          logger.debug('Cancelled Facebook Link')
          return;
        case RESPONSES.ACCESS_TOKEN_INVALID:
          logger.warning('onLinkFacebook generated invalid access token.');
          displayFacebookError();
          return;
        default:
          logger.error(err);
          displayFacebookError();
      }
    })
  }

  hidePopup() {
    this.props.dispatch({
      type: 'CLOSE_DIALOG'
    })
  }

  upgrade() {
    logger.debug('Upgraded from Apphub');

    this.props.dispatch({
      type: 'FINISHED_UPGRADING_APPHUB'
    })

    return BridgeManager.reloadBridge();
  }

  hardUpgrade() {
    if (this.props.dialog.hardUpgradeURL) {
      LinkingIOS.canOpenURL(this.props.dialog.hardUpgradeURL, (supported) => {
        if (!supported) {
          logger.warning(`Hard Upgrade: ${this.props.dialog.hardUpgradeURL} unsupported.`)
          return;
        } else {
          LinkingIOS.openURL(this.props.dialog.hardUpgradeURL);
        }
      })
    }
  }

  closeNetworkConnectingPopup() {
    this.props.dispatch({
      type: 'HIDE_BANNER',
    })
  }

  render() {
    return (
      <View style={{ flex: 1 }}>
        <NetworkStatusOverlay
          isVisible={this.props.shouldShowNetworkBanner}
          closePopup={this.closeNetworkConnectingPopup.bind(this)}/>

        <OverlayLoader isVisible={this.props.showOverlayLoader} />

        <PopupDialog
          isVisible={this.props.dialog.visible}
          actionKey={this.props.dialog.actionKey}
          title={this.props.dialog.title}
          message={this.props.dialog.message}
          buttons={this.props.dialog.buttons}
          upgrade={this.upgrade.bind(this)}
          hardUpgrade={this.hardUpgrade.bind(this)}
          hidePopup={this.hidePopup.bind(this)} />

        <FullScreenNavigator
          style={{ flex: 1 }}
          sceneStyle={{ paddingTop: 64 }}
          upgrade={this.upgrade.bind(this)}
          onFetchCourses={this.onFetchCourses.bind(this)}
          onRemoveCourse={this.onRemoveCourse.bind(this)}
          onPressLogin={this.onPressLogin.bind(this)}
          onPressLogout={this.onPressLogout.bind(this)}
          onUploadImage={this.onUploadImage.bind(this)}
          onLinkFacebook={this.onLinkFacebook.bind(this)}
        />
      </View>
    )
  }
}

export default connect(mapStateToProps)(LayoutContainer)
