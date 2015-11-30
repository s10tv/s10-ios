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

class Session {
  constructor(store) {
  }
}

export { TSSession }