'use strict';

let {
  NativeAppEventEmitter,
  NativeModules: {
    TSSession,
  },
} = require('react-native');

const logger = new (require('../modules/Logger'))('Session.js');

logger.debug('Will initialize session');

class Session {
  initialValue() {
    logger.debug(`session initial value: ${JSON.stringify(TSSession.initialValue)}`)
    return TSSession.initialValue;
  }

  login(userId, resumeToken, expiryDate) {
    logger.debug(`Calling login with userId:${userId} resumeToken=${resumeToken}`)
    return TSSession.login(userId, resumeToken, expiryDate);
  }

  logout() {
    return TSSession.logout()
  }
}

logger.debug(`Session initialValue=${JSON.stringify(TSSession.initialValue)}`);
logger.debug('Did initialize session');

module.exports = new Session();
