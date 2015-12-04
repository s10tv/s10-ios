import React, {
  View,
} from 'react-native';

let Router = {
  login() {
    return {
      // You can also render a scene yourself when you need more control over
      // the props of the scene component
      renderScene(navigator) {
        let LoginScreen = require('./components/onboarding/LoginScreen');
        return <LoginScreen navigator={navigator} />;
      },

      renderTitle() {
        return null
      },
    };
  },

};

module.exports = Router;
