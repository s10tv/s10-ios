/**
 * @flow
 */
'use strict';

const React = require('react-native');
const {
  NativeModules: {
    TSBridgeManager,
  },
} = React;


class BridgeManager {

  static isRunningInSimulator() {
    return TSBridgeManager.isRunningInSimulator;
  }

  static isRunningTestFlightBeta() {
    return TSBridgeManager.isRunningTestFlightBeta;
  }

  static async getDefaultAccountAsync() {
    return TSBridgeManager.getDefaultAccountAsync();
  }
  // expects
  // {userId: string, resumeToken: string, expiryDate: number? } 
  // TODO: Convert JS Date to nsnumber inside the wrapper, also make this strongly typed via flow?
  static setDefaultAccount(account) {
    TSBridgeManager.setDefaultAccount(account);
  }
}

module.exports = BridgeManager;