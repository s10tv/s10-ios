
const React = require('react-native');
const {
  NativeModules: {
    TSIntercomProvider,
  },
} = React;

class Intercom {
  static async setHMAC(hmac, data) {
    console.log('setting hmac', hmac, data);
    return TSIntercomProvider.setHMAC(hmac, data);
  }
}

module.exports = Intercom;