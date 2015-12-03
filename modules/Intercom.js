
const React = require('react-native');
const {
  NativeModules: {
    TSIntercomProvider,
  },
} = React;

const logger = new (require('./Logger'))('Intercom');

class Intercom {
  static async setHMAC(hmac, data) {
    logger.debug(`setting hmac for userId=${data}`)
    return TSIntercomProvider.setHMAC(hmac, data);
  }
}

module.exports = Intercom;
