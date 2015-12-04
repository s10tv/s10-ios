import React, {
  StyleSheet,
  View,
  Text,
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

// constants
const logger = new (require('../../../modules/Logger'))('LoginScreen');

class LoginScreen extends React.Component {

  onFacebookLogin(err, res) {
    if (err) {
      logger.error(err);

      this.props.dispatch({
        type: 'DISPLAY_ERROR',
        title: 'Facebook Login',
        message: 'There was a problem logging you into Taylr :C Please try again later.',
      })

      return;
    }

    if (res.isCancelled) {
      logger.info('Welcome: Cancelled FB Verification');
      return;
    }

    FBSDKAccessToken.getCurrentAccessToken((accessToken) => {
      if (accessToken && accessToken.tokenString) {
        return new FacebookLoginHandler(this.props.ddp)
          .onLogin(accessToken.tokenString, this.props.dispatch);
      }
    });
  }

  render() {
    return (
      <FBSDKLoginButton
        onLoginFinished={this.onFacebookLogin.bind(this)}
        onLogoutFinished={() => console.log('on logout') }
        readPermissions={['email', 'public_profile', 'user_about_me',
          'user_birthday', 'user_education_history',
          'user_friends', 'user_location', 'user_photos', 'user_posts']}
        publishPermissions={[]}
      />
    )
  }
}

function mapStateToProps(state) {
  return {
    ddp: state.ddp
  }
}

export default connect(mapStateToProps)(LoginScreen)
