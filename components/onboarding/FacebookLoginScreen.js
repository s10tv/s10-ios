let React = require('react-native');

let {
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
} = React;

let Dimensions = require('Dimensions');
let { width, height } = Dimensions.get('window');

var FBSDKLogin = require('react-native-fbsdklogin');
var {
  FBSDKLoginButton,
  FBSDKLoginManager,
} = FBSDKLogin;

var FBSDKCore = require('react-native-fbsdkcore');
var {
  FBSDKAccessToken,
} = FBSDKCore;

var Digits = require('react-native-fabric-digits');
var { DigitsLoginButton, DigitsLogoutButton } = Digits;

var Video = require('react-native-video');

let SHEET = require('../CommonStyles').SHEET;
let COLORS = require('../CommonStyles').COLORS;

class FacebookLoginScreen extends React.Component {

  login(error, response) {
    if (error) {
      return;
    }

    // we convert userId to id on the server, so the userId better be set.
    response.userId = response.userID;

    this.props.ddp.call({ methodName: 'login', params: [{ digits: response }]})
    .then((result) => {
      this.props.ddp.__onLogin.bind(this.props.ddp)(result);
      this.props.onLogin({
        userId: result.id,
        token: result.token,
        tokenExpires: result.tokenExpires,
      });
    })
    .catch((err) => {
      console.error(err); 
    })
  }

  __facebookLogin() {
    FBSDKLoginManager.logInWithReadPermissions([], (error, result) => {
      if (error) {
        console.log(error);
        alert('Error logging you in. Please try again later');
      } else {
        if (result.isCancelled) {
          console.log('cancelled login');
        } else {
          FBSDKAccessToken.getCurrentAccessToken((accessToken) => {
            if (accessToken && accessToken.tokenString) {
              this.props.ddp.call({
                methodName: 'login',
                params: [{ facebook: { accessToken: accessToken.tokenString }}]})
              .then((result) => {
                this.props.ddp.__onLogin.bind(this.props.ddp)(result);
                this.props.onLogin({
                  userId: result.id,
                  token: result.token,
                  tokenExpires: result.tokenExpires,
                });
              })
              .catch(err => {
                console.error(err);
              })
            }
          });
        }
      }
    });
  }

  render() {
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
        <View style={styles.loginSheet}>
          <FBSDKLoginButton
            style={styles.fbButton}
            onLoginFinished={(error, result) => {
              if (error) {
                alert('Error logging in.');
              } else {
                if (result.isCancelled) {
                  alert('Login cancelled.');
                } else {
                  FBSDKAccessToken.getCurrentAccessToken((accessToken) => {
                    if (accessToken && accessToken.tokenString) {
                      this.props.ddp.call({
                        methodName: 'login',
                        params: [{ facebook: { accessToken: accessToken.tokenString }}]})
                      .then((result) => {
                        this.props.ddp.__onLogin.bind(this.props.ddp)(result);
                        this.props.onLogin({
                          userId: result.id,
                          token: result.token,
                          tokenExpires: result.tokenExpires,
                        });
                      })
                      .catch(err => {
                        console.error(err);
                      })
                    }
                  });
                }
              }
            }}
            onLogoutFinished={() => console.log('logged out')}
            readPermissions={[]}
            publishPermissions={[]}/>

          <View style={{ marginTop: height / 24 }}>
            <DigitsLoginButton
              options={{
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
              }}
              buttonStyle={{ backgroundColor : 'rgba:(0,0,0,0)'}}
              textStyle={[{padding: 5}, styles.link]}
              completion={this.login.bind(this)}
              text="Login with Phone" />
          </View>
        </View>
        <View style={styles.bottomSheet}>
          <View style={{ flexDirection: 'row' }}>
          <Text style={styles.link}>Privacy</Text>
          <Text style={styles.link}>Terms</Text>
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
  },
  loginText: {
    flex: 1,
    fontSize: 18,
    color: 'white',
    textAlign: 'center'
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
    fontSize: 10,  
    color: COLORS.white,
    padding: 2,
    textDecorationLine: 'underline',
  },
});

module.exports = FacebookLoginScreen;