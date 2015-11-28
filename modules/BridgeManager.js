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

  static serverUrl() {
    return TSBridgeManager.serverUrl;
  }

  static bundleUrlScheme() {
    return TSBridgeManager.bundleUrlScheme;
  }

  static audience() {
    return TSBridgeManager.audience;
  }

  static appId() {
    return TSBridgeManager.appId;
  }

  static version() {
    return TSBridgeManager.version;
  }

  static build() {
    return TSBridgeManager.build;
  }

  static deviceId() {
    return TSBridgeManager.deviceId;
  }

  static deviceName() {
    return TSBridgeManager.deviceName;
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

  static registerForPushNotifications() {
    TSBridgeManager.registerForPushNotifications();
  }
}

module.exports = BridgeManager;