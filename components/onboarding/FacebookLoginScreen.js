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

var FBSDKLogin = require('react-native-fbsdklogin');
var {
  FBSDKLoginButton,
} = FBSDKLogin;

var FBSDKCore = require('react-native-fbsdkcore');
var {
  FBSDKAccessToken,
} = FBSDKCore;

var Digits = require('react-native-fabric-digits');
var { DigitsLoginButton, DigitsLogoutButton } = Digits;



let SHEET = require('../CommonStyles').SHEET;
let COLORS = require('../CommonStyles').COLORS;

class FacebookLoginScreen extends React.Component {

  // ...

  login(error, response) {
    console.log(error);
    console.log(response);
    // Your code here.
    response.userId = response.userID;
    console.log(response);

    this.props.ddp.call({ methodName: 'login', params: [{ digits: response }]})
    .then((result) => {
      console.log(result);
      this.props.ddp.__onLogin.bind(this.props.ddp)(result);
      this.props.onLogin();
    })
    .catch((err) => {
      console.error(err); 
    })
  }

  logout(error, response) {
    console.log(error);
    console.log(response);
  }

  __login(error, result) {
    if (error) {
      alert('Error logging in.');
    } else {
      if (result.isCancelled) {
        alert('Login cancelled.');
      } else {
        alert('Logged in.');
        FBSDKAccessToken.getCurrentAccessToken((accessToken) => {
          if (accessToken && accessToken.tokenString) {


          }
        });
      } 
    }
  }

  render() {


    return (
      <View style={SHEET.container}>
        <View style={[SHEET.innerContainer, SHEET.navTop]}>
          <FBSDKLoginButton
            onLoginFinished={this.__login.bind(this)}
            onLogoutFinished={() => alert('Logged out.')}
            readPermissions={[]}
            publishPermissions={['publish_actions']}/>

            <DigitsLoginButton
              options={{
                title: "Connect with your phone",
                appearance: {
                  backgroundColor: {
                    hex: "#ffffff",
                    alpha: 1.0
                  },
                  accentColor: {
                    hex: "#43a16f",
                    alpha: 0.7
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
              completion={this.login.bind(this)}
              text="Use my phone number" />

            <DigitsLogoutButton
              completion={this.logout.bind(this)}
              text="Logout" />
        </View>
      </View>
    ) 
  } 
}

module.exports = FacebookLoginScreen;