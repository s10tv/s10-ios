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
let LayerService = require('./lib/LayerService');
let BridgeManager = require('./modules/BridgeManager');
const logger = new (require('./lib/Logger'))('index.ios');
let LayoutContainer = require('./components/LayoutContainer');

// polyfill the process functionality needed
global.process = require("./lib/process.polyfill");

logger.info('JS App Launched');
logger.debug(`bundle url ${BridgeManager.bundleUrlScheme()}`);

let ddp = new TSDDPClient(BridgeManager.serverUrl());
let layerService = new LayerService();

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
    return <LayoutContainer ddp={ddp} layerService={layerService} />;
  }
}

AppRegistry.registerComponent('Taylr', () => Main);
