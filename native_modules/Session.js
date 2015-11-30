/**
 * @flow
 */
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
  constructor(store) {
  }

}

logger.debug(`Session initialValue=${JSON.stringify(TSSession.initialValue)}`);
logger.debug('Did initialize session');


export default TSSession