/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 */
'use strict';
let Analytics = require('react-native').NativeModules.TSAnalytics;
let Logger = require('react-native').NativeModules.TSLogger;
let TSLayerService = require('react-native').NativeModules.TSLayerService;
let TSDDPClient = require('./lib/ddpclient');
let BridgeManager = require('./modules/BridgeManager');
let React = require('react-native');
let {
  AppRegistry,
  NativeAppEventEmitter,
} = React;

// polyfill the process functionality needed
global.process = require("./lib/process.polyfill");

let LayoutContainer = require('./components/LayoutContainer');

let ddp = new TSDDPClient(
  'wss://s10-dev.herokuapp.com/websocket'
);

let container = React.createClass({
  render: function() {
    return <LayoutContainer ddp={ddp} />;
  }
});

AppRegistry.registerComponent('Taylr', () => container);

//Analytics.identify('TestUserId');
// Analytics.track('JS App Launched', null);
Logger.log('My Log Statement', 'info', 'root', 'index.ios.js', 232);

BridgeManager.getDefaultAccountAsync().then((account) => {
	console.log('default account is', account);
});

NativeAppEventEmitter.addListener('RegisteredPushToken', (tokenInfo) => {
  ddp.call({ methodName: 'device/update/push', params: tokenInfo })
});