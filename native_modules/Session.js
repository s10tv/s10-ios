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

  constructor() {
    console.log('real session');
  }

  initialValue() {
    return true;
  }
}

logger.debug(`Session initialValue=${JSON.stringify(TSSession.initialValue)}`);
logger.debug('Did initialize session');

module.exports = Session;
