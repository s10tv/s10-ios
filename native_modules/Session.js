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
  static instance = new Session()

  initialValue() {
    logger.debug(`session initial value: ${JSON.stringify(TSSession.initialValue)}`)
    return TSSession.initialValue;
  }

  setUsername(username) {
    return TSSession.setUsername(username);
  }

  setPhone(phone) {
    return TSSession.setPhone(phone);
  }

  setEmail(email) {
    return TSSession.setEmail(email);
  }

  setFirstName(firstName) {
    return TSSession.setFirstName(firstName);
  }

  setLastName(lastName) {
    return TSSession.setLastName(lastName);
  }

  setFullname(fullName) {
    return TSSession.setFullname(fullName);
  }

  setDisplayName(displayName) {
    return TSSession.setDisplayName(displayName);
  }

  setAvatarURL(avatarURL) {
    return TSSession.setAvatarURL(avatarURL);
  }

  setCoverURL(coverURL) {
    return TSSession.setCoverURL(coverURL);
  }

  login(userId, resumeToken, expiryDate) {
    return TSSession.login(userId, resumeToken, expiryDate);
  }

  logout() {
    return TSSession.logout()
  }
}

logger.debug(`Session initialValue=${JSON.stringify(TSSession.initialValue)}`);
logger.debug('Did initialize session');

module.exports = Session.instance
