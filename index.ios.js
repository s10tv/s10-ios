/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 */
'use strict';
let Analytics = require('react-native').NativeModules.TSAnalytics;
let Logger = require('react-native').NativeModules.TSLogger;
let TSLayerService = require('react-native').NativeModules.TSLayerService;
let React = require('react-native');
let {
  AppRegistry,
  NativeAppEventEmitter,
} = React;

// polyfill the process functionality needed
global.process = require("./lib/process.polyfill");

TSLayerService.connect((err) => {
	if (err != null) {
		console.log('Unable to connect to Layer', err);
	} else {
		console.log('Successfully connected to Layer');
	}
});

let LayoutContainer = require('./components/LayoutContainer');

let container = React.createClass({
  render: function() {
    return <LayoutContainer wsurl={'wss://s10-dev.herokuapp.com/websocket'} />;
  }
});

AppRegistry.registerComponent('Taylr', () => container);
Analytics.identify('TestUserId');
Analytics.track('JS App Launched', null);
Logger.log('My Log Statement', 'info', 'root', 'index.ios.js', 232);
