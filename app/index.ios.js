/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 */
'use strict';

let ddp = require('./lib/ddp');
let TaylrAPI = require('react-native').NativeModules.TaylrAPI;
let React = require('react-native');
let {
  AppRegistry,
  NativeAppEventEmitter,
} = React;

// polyfill the process functionality needed
global.process = require("./lib/process.polyfill")

let LayoutContainer = require('./components/LayoutContainer');

let container = React.createClass({
  render: function() {
    return <LayoutContainer />;
  }
});

AppRegistry.registerComponent('TaylrReact', () => container);

// ddp.initialize().then((res) => {
// 	TaylrAPI.getMeteorUser((userId, resumeToken) => {
// 	  if (resumeToken != null) {
// 	  	ddp.loginWithToken(resumeToken);
// 	  }
// 	});
// })
var subscription = NativeAppEventEmitter.addListener(
  'Example',
  (data) => console.log(data)
);
// ...
// // Don't forget to unsubscribe, typically in componentWillUnmount
// subscription.remove();