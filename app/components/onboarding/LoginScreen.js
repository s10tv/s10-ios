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
  StyleSheet,
} from 'react-native';

import FBSDKLogin, {
  FBSDKLoginButton,
  FBSDKLoginManager,
} from 'react-native-fbsdklogin';

import FBSDKCore, {
  FBSDKAccessToken,
} from 'react-native-fbsdkcore';

import { connect } from 'react-redux/native';

// internal dependencies
import FacebookLoginHandler from './FacebookLoginHandler';

import Screen from '../Screen';
import { Card } from '../lib/Card';
import { SCREEN_OB_LOGIN } from '../../constants';
import { SHEET, COLORS } from '../../CommonStyles';


let Dimensions = require('Dimensions');
let { width, height } = Dimensions.get('window');
let Video = require('react-native-video');

// constants
const logger = new (require('../../../modules/Logger'))('LoginScreen');

function mapStateToProps(state) {
  return {
    ddp: state.ddp,
    me: state.me,
  }
}

class LoginScreen extends Screen {
  static id = SCREEN_OB_LOGIN;
  static leftButton = () => null
  static rightButton = (route, router) => null
  static title = () => null

  constructor(props = {}) {
    super(props);
    this.facebookLoginHandler = new FacebookLoginHandler(props.ddp);
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
      return this.props.onPressLogin(result)
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
              this.props.toSceneAfterLogin()
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
            onLogoutFinished={() => this.props.onPressLogout }
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
                  .authenticateDigitsWithOptions(options, this.digitsLogin.bind(this));
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
            this.props.navigator.push({
              id: 'openwebview',
              url: 'https://taylrapp.com/privacy'
            })
          }}>Privacy</Text>
          <Text style={[styles.link, SHEET.baseText]} onPress={() => {
            this.props.navigator.push({
              id: 'openwebview',
              url: 'https://taylrapp.com/terms'
            })
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
