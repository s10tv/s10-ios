/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 */
'use strict';
let React = require('react-native');
let {
  AppRegistry,
  NativeAppEventEmitter,
  NativeModules: {
    AppHub,
  },
} = React;

let TSDDPClient = require('./lib/ddpclient');
let BridgeManager = require('./modules/BridgeManager');

import ApphubService from './components/upgrade/ApphubService';
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
  apphub: ApphubService.apphub,
  modalVisible: ApphubService.modalVisible,
  hardUpgradeURL: ApphubService.hardUpgradeURL,
}))

let ddp = new TSDDPClient(BridgeManager.serverUrl());
let layerService = new LayerService(store);
let apphubService = new ApphubService(store);

NativeAppEventEmitter.addListener('RegisteredPushToken', (tokenInfo) => {
  logger.debug(`[PUSH]: did receive RegisteredPushToken. ${JSON.stringify(tokenInfo)}`);

  if (!tokenInfo) {
    logger.debug('[PUSH]: Register push token called with no token');
    return;
  }

  tokenInfo.appId = BridgeManager.appId();
  tokenInfo.version = BridgeManager.version();
  tokenInfo.build = BridgeManager.build();
  tokenInfo.deviceId = BridgeManager.deviceId();
  tokenInfo.deviceName = BridgeManager.deviceName();

  logger.debug(`[PUSH]: will call device/update/push with ${JSON.stringify(tokenInfo)}`);

  ddp.call({ methodName: 'device/update/push', params: [tokenInfo] })
  .then(() => {
    logger.debug('[PUSH]: Registered Push Token');
  })
  .catch(err => {
    logger.error(err);
  })
});

class Main extends React.Component {
  render() {
    return <LayoutContainer ddp={ddp} store={store} />;
  }
}

AppRegistry.registerComponent('Taylr', () => Main);
