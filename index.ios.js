/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 */
'use strict';
let React = require('react-native');
let {
  AppRegistry,
  NativeAppEventEmitter,
} = React;

let TSDDPClient = require('./lib/ddpclient');
let BridgeManager = require('./modules/BridgeManager');

import { LayerService } from './modules/LayerService';
import { LayoutContainer } from './components/LayoutContainer';
import { createStore, combineReducers } from 'redux';

const logger = new (require('./modules/Logger'))('index.ios');

// polyfill the process functionality needed
global.process = require("./lib/process.polyfill");

logger.info('JS App Launched');
logger.debug(`bundle url ${BridgeManager.bundleUrlScheme()}`);

let store = createStore(combineReducers({
  allConversationCount: LayerService.allConversationCount,
  unreadConversationCount: LayerService.unreadConversationCount,
}))

let ddp = new TSDDPClient(BridgeManager.serverUrl());
let layerService = new LayerService(store);

NativeAppEventEmitter.addListener('RegisteredPushToken', (tokenInfo) => {
  if (!tokenInfo) {
    TSLogger.log('Register push token called with no token', 'warning', 'index.io.js', '', 0);
    return;
  }

  tokenInfo.appId = BridgeManager.appId();
  tokenInfo.version = BridgeManager.version();
  tokenInfo.build = BridgeManager.build();
  tokenInfo.deviceId = BridgeManager.deviceId();
  tokenInfo.deviceName = BridgeManager.deviceName();

  ddp.call({ methodName: 'device/update/push', params: tokenInfo })
  .then(() => {
    logger.debug('Registered push token', 'debug', 'index.io.js', '', 0);
  })
  .catch(err => {
    logger.debug(JSON.stringify(err), 'error', 'index.io.js', '', 0);
  })
});

class Main extends React.Component {
  render() {
    return <LayoutContainer ddp={ddp} store={store} />;
  }
}

AppRegistry.registerComponent('Taylr', () => Main);
