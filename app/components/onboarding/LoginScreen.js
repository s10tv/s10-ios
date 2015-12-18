import React, {
  AppRegistry,
  View,
  Text,
  Image,
  TouchableOpacity,
  Navigator,
  NavigatorIOS,
  TabBarIOS,
  WebView,
  PropTypes,
  StyleSheet,
} from 'react-native';

import FBSDKLogin, {
  FBSDKLoginButton,
  FBSDKLoginManager,
} from 'react-native-fbsdklogin';

import FBSDKCore, {
  FBSDKAccessToken,
} from 'react-native-fbsdkcore';

import { DigitsAuthenticateManager } from 'react-native-fabric-digits'

import { connect } from 'react-redux/native';

// internal dependencies
import FacebookLoginHandler from './FacebookLoginHandler';
import DigitsLoginHandler from './DigitsLoginHandler';

import { Card } from '../lib/Card';
import { SHEET, COLORS } from '../../CommonStyles';
import Routes from '../../nav/Routes'

import Intercom from '../../../modules/Intercom';

let Dimensions = require('Dimensions');
let { width, height } = Dimensions.get('window');
let Video = require('react-native-video');

const logger = new (require('../../../modules/Logger'))('LoginScreen');

function mapStateToProps(state) {
  return {
    loggedIn: state.loggedIn,
    isActive: state.isActive,
    ddp: state.ddp,
    me: state.me,
  }
}

class LoginScreen extends React.Component {
  static propTypes = {
    onPressLogin: PropTypes.func.isRequired,
    onPressLogout: PropTypes.func.isRequired,
    navigator: PropTypes.object.isRequired,
  }

  constructor(props = {}) {
    super(props);
    this.facebookLoginHandler = new FacebookLoginHandler(props.ddp);
    this.digitsLoginHandler = new DigitsLoginHandler(props.ddp);
  }

  componentWillMount() {
    this.props.dispatch({
      type: 'HIDE_NAV_BAR'
    })
  }

  _getRouteAfterLogin(isActive) {
    if (isActive) {
      return Routes.instance.getMainNavigatorRoute();
    } else {
      return Routes.instance.getOnboardingRoute();
    }
  }

  onDigitsLogin(error, response) {
    if (error) {
      // warning here because when you click 'cancel' that also results in an error.
      logger.warning(JSON.stringify(error))
      return;
    }

    // we convert userId to id on the server, so the userId better be set.
    response.userId = response.userID;

    this.digitsLoginHandler.onLogin(response, this.props.dispatch)
    .then((result) => {
      const { intercomHash, userId } = result;
      Intercom.setHMAC(intercomHash, userId);

      this.props.onPressLogin(result)

      const route = this._getRouteAfterLogin(result.isActive);
      this.props.navigator.push(route)
    })
    .catch(err => {
      logger.error(err)
    })
  }

  onFacebookLogin(err, res) {
    if (err) {
      this.props.dispatch({
        type: 'DISPLAY_ERROR',
        title: 'Facebook Login',
        message: 'There was a problem logging you into Taylr :C Please try again later.',
      })

      logger.error(err);
      return;
    }

    if (res.isCancelled) {
      logger.info('Welcome: Cancelled FB Verification');
      return;
    }

    return new Promise((resolve) => {
      FBSDKAccessToken.getCurrentAccessToken((accessToken) => {
        return resolve(accessToken);
      })
    }).then((accessToken) => {
      if (accessToken && accessToken.tokenString) {
        return this.facebookLoginHandler.onLogin(accessToken.tokenString, this.props.dispatch)
      }
      return Promise.reject('No Token');
    })
    .then((result) => {
      const { intercomHash, userId } = result;
      Intercom.setHMAC(intercomHash, userId);

      this.props.onPressLogin(result)

      const route = this._getRouteAfterLogin(result.isActive);
      this.props.navigator.push(route)
    })
    .catch(err => {
      logger.error(err)
    })
  }

  render() {
    let me = this.props.me;

    let logoutComponent = null;
    let loginComponent = null;

    if (this.props.loggedIn) {

      let buttonText = 'Continue';
      if (me && (me.firstName || me.lastName)) {
        buttonText = `Continue as ${me.firstName} ${me.lastName}`
      }

      loginComponent = (
        <View style={styles.loginSheet}>
          <TouchableOpacity
            onPress={() => {
              const route = this._getRouteAfterLogin(this.props.isActive);
              this.props.navigator.push(route)
            }}>
              <View style={{ padding:10, borderColor: 'white', borderWidth: 1}}>
                <Text style={[SHEET.baseText, {fontSize: 18, color: 'white'}]}>
                  {buttonText}
                </Text>
              </View>
          </TouchableOpacity>
        </View>
      )

      logoutComponent = (
        <Text style={[styles.link, SHEET.baseText]} onPress={() => {
          this.props.onPressLogout()
        }}>Logout</Text>
      )
    } else {
      loginComponent = (
        <View style={styles.loginSheet}>
          <FBSDKLoginButton
            style={styles.fbButton}
            onLoginFinished={this.onFacebookLogin.bind(this)}
            onLogoutFinished={() => this.props.onPressLogout() }
            readPermissions={['email', 'public_profile', 'user_about_me',
              'user_birthday', 'user_education_history',
              'user_friends', 'user_location', 'user_photos', 'user_posts']}
            publishPermissions={[]}/>

          <View style={{ marginTop: height / 24 }}>

            <Text
              style={[{padding: 5}, styles.link, SHEET.baseText]}
              onPress={() => {
                let options = {
                  title: "Taylr",
                  appearance: {
                    backgroundColor: {
                      hex: "#ffffff",
                      alpha: 1.0
                    },
                    accentColor: {
                      hex: COLORS.taylr,
                      alpha: 1,
                    },
                    headerFont: {
                      name: "Arial",
                      size: 16
                    },
                    labelFont: {
                      name: "Helvetica",
                      size: 18
                    },
                    bodyFont: {
                      name: "Helvetica",
                      size: 16
                    }
                  }
                }

                DigitsAuthenticateManager
                  .authenticateDigitsWithOptions(options, this.onDigitsLogin.bind(this));
            }}>Login with Phone</Text>
          </View>
        </View>
      );
    }

    return (
      <View style={SHEET.container}>
        <Video source={{uri: "background"}} // Can be a URL or a local file.
           rate={1.0}                   // 0 is paused, 1 is normal.
           volume={1.0}                 // 0 is muted, 1 is normal.
           muted={false}                // Mutes the audio entirely.
           paused={false}               // Pauses playback entirely.
           resizeMode="cover"           // Fill the whole screen at aspect ratio.
           repeat={true}                // Repeat forever.
           onLoadStart={this.loadStart} // Callback when video starts to load
           onLoad={this.setDuration}    // Callback when video loads
           onProgress={this.setTime}    // Callback every ~250ms with currentTime
           onEnd={this.onEnd}           // Callback when playback finishes
           onError={this.videoError}    // Callback when video cannot be loaded
           style={styles.backgroundVideo} />

        <View style={[styles.backgroundVideo, { backgroundColor: 'black', opacity: 0.5}]} />

        <View style={styles.content}>
          <Image source={require('../img/logo.png')} style={styles.logo} />

          <View style={styles.description}>
            <Text style={[styles.descText, SHEET.baseText]}>
              Branch out.
            </Text>
            <Text style={[styles.descText, SHEET.baseText]}>
              Expand your social and professional networks.
            </Text>
          </View>
        </View>

        {loginComponent}

        <View style={styles.bottomSheet}>
          <View style={{ flexDirection: 'row' }}>
          <Text style={[styles.link, SHEET.baseText]} onPress={() => {
            const route = Routes.instance.getWebviewLinkRoute(
              'Privacy', 'https://taylrapp.com/privacy');
            this.props.navigator.push(route);
          }}>Privacy</Text>
          <Text style={[styles.link, SHEET.baseText]} onPress={() => {
            const route = Routes.instance.getWebviewLinkRoute(
              'Terms', 'https://taylrapp.com/terms');
            this.props.navigator.push(route);
          }}>Terms</Text>
          {logoutComponent}
          </View>
        </View>
      </View>
    )
  }
}

var styles = StyleSheet.create({
  backgroundVideo: {
    position: 'absolute',
    top: 0,
    left: 0,
    bottom: 0,
    right: 0,
  },
  content: {
    flex: 1,
    top: width / 4,
    alignItems: 'center',
    backgroundColor: 'rbga:(0,0,0,0)',
  },
  logo: {
    resizeMode: 'contain',
    width: width / 1.5,
    height: width / 2,
  },
  description: {
    alignItems: 'center',
  },
  descText: {
    flex: 1,
    marginTop: 20,
    fontSize: 18,
    color: COLORS.white,
    textAlign: 'center',
  },
  loginSheet: {
    position: 'absolute',
    width: width,
    alignItems: 'center',
    bottom: width / 4,
    backgroundColor: 'rbga:(0,0,0,0)',
  },
  fbButton: {
    height: 0.75 * width * 0.15,
    width: width * 0.75,
    flexDirection: 'row',
    alignItems: 'center',
    fontSize: 24,
  },
  bottomSheet: {
    position: 'absolute',
    width: width,
    alignItems: 'center',
    bottom: height / 24,
    backgroundColor: 'rbga:(0,0,0,0)',
  },
  link: {
    backgroundColor: 'rgba:(0,0,0,0)',
    fontSize: 14,
    color: COLORS.white,
    padding: 2,
    textDecorationLine: 'underline',
  },
});

export default connect(mapStateToProps)(LoginScreen)
