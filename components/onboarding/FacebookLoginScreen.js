let React = require('react-native');

let {
  AppRegistry,
  ActivityIndicatorIOS,
  View,
  Text,
  Image,
  TouchableOpacity,
  Navigator,
  NavigatorIOS,
  TabBarIOS,
  WebView,
  StyleSheet,
} = React;

let Dimensions = require('Dimensions');
let { width, height } = Dimensions.get('window');

let FBSDKLogin = require('react-native-fbsdklogin');
let {
  FBSDKLoginButton,
  FBSDKLoginManager,
} = FBSDKLogin;

let FBSDKCore = require('react-native-fbsdkcore');
let {
  FBSDKAccessToken,
} = FBSDKCore;

let Digits = require('react-native-fabric-digits');
let { DigitsAuthenticateManager } = Digits;

let Video = require('react-native-video');
let Button = require('react-native-button');

let Analytics = require('../../modules/Analytics');
let SHEET = require('../CommonStyles').SHEET;
let COLORS = require('../CommonStyles').COLORS;

let Logger = require('../../lib/Logger');

class FacebookLoginScreen extends React.Component {

  constructor(props) {
    super(props);
    this.logger = new Logger(this);
  }

  digitsLogin(error, response) {
    if (error) {
      // warning here because when you click 'cancel' that also results in an error.
      this.logger.warning(JSON.stringify(error))
      return;
    }

    // we convert userId to id on the server, so the userId better be set.
    response.userId = response.userID;

    this.props.ddp.call({ methodName: 'login', params: [{ digits: response }]})
    .then((result) => {
      this.props.ddp.__onLogin.bind(this.props.ddp)(result);
      this.props.onLogin({
        userId: result.id,
        resumeToken: result.token,
        expiryDate: result.tokenExpires.getTime(),
        isNewUser: result.isNewUser,
        userTriggered: true,
        intercom: {
          hmac: result.intercomHash,
          data: result.id,
        },
      });

      if (result.isNewUser) {
        Analytics.track('Signup: Start');
        this.transitionToNextScene();
      }
    })
    .catch((err) => {
      this.logger.error(JSON.stringify(err)); 
    })
  }

  transitionToNextScene() {
    if (this.props.isCWLRequired) {
      this.props.navigator.push({
        id: 'joinnetwork',
        title: 'UBC'
      });
    } else {
      this.props.navigator.push({
        id: 'linkservicecontainer',
        title: 'Connect Services'
      }); 
    }
  }

  render() {
    let me = this.props.me;

    let logoutComponent = null;
    let loginComponent = null;

    if (this.props.loggedIn && me) {

      let buttonText = 'Continue';
      if (me.firstName || me.lastName) {
        buttonText = `Continue as ${me.firstName} ${me.lastName}`
      }

      loginComponent = (
        <View style={styles.loginSheet}>
          <Button
            onPress={() => {
              this.transitionToNextScene() 
            }}>
              <View style={{ padding:10, borderColor: 'white', borderWidth: 1}}>
                <Text style={[SHEET.baseText, {fontSize: 18, color: 'white'}]}>
                  {buttonText} 
                </Text>
              </View>
          </Button>
        </View>
      )

      logoutComponent = (
        <Text style={[styles.link, SHEET.baseText]} onPress={() => {
          this.props.onLogout()
        }}>Logout</Text>
      )
    } else if (this.props.loggedIn == false) {
      loginComponent = (
        <View style={styles.loginSheet}>
          <FBSDKLoginButton
            style={styles.fbButton}
            onLoginFinished={(error, result) => {
              if (error) {
                this.logger.error(`Error logging in with Facebook ${JSON.stringify(error)}`);
                alert('Error logging you in :C Please try again later.');
              } else {
                if (!result.isCancelled) {
                  FBSDKAccessToken.getCurrentAccessToken((accessToken) => {
                    if (accessToken && accessToken.tokenString) {
                      this.props.ddp.call({
                        methodName: 'login',
                        params: [{ facebook: { accessToken: accessToken.tokenString }}]})
                      .then((result) => {
                        this.props.ddp.__onLogin.bind(this.props.ddp)(result);
                        this.props.onLogin({
                          userId: result.id,
                          resumeToken: result.token,
                          expiryDate: result.tokenExpires.getTime(),
                          isNewUser: result.isNewUser,
                          intercom: {
                            hmac: result.intercomHash,
                            data: result.id,
                          },
                          userTriggered: true,
                        });

                        if (result.isNewUser) {
                          Analytics.track('Signup: Start');
                          this.transitionToNextScene();
                        }
                      })
                      .catch(err => {
                        this.logger.error(JSON.stringify(error));
                      })
                    } else {
                      this.logger.info('Welcome: Cancelled FB Verification'); 
                    }
                  });
                }
              }
            }}
            onLogoutFinished={() => this.props.onLogout }
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
    } else {
      loginComponent = (
        <View style={styles.loginSheet}>
          <ActivityIndicatorIOS
            animating={true}
            style={{ justifyContent: 'center' }}
            size="small" />
        </View>
      )
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

module.exports = FacebookLoginScreen;