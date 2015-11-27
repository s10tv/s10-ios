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
let TSLogger = React.NativeModules.TSLogger; // not wrapping because dont have callerInstance.
let LayoutContainer = require('./components/LayoutContainer');

// polyfill the process functionality needed
global.process = require("./lib/process.polyfill");

TSLogger.log('JS App Launched', 'debug', 'index.io.js', '', 0);
let ddp = new TSDDPClient(
  'wss://s10-dev.herokuapp.com/websocket'
);

NativeAppEventEmitter.addListener('RegisteredPushToken', (tokenInfo) => {
  ddp.call({ methodName: 'device/update/push', params: tokenInfo })
  .then(() => {
    TSLogger.log('Registered push token', 'debug', 'index.io.js', '', 0);
  })
});

class Main extends React.Component {
  render() {
    return <LayoutContainer ddp={ddp} />;
  }
}

AppRegistry.registerComponent('Taylr', () => Main);
