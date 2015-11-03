/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 */
'use strict';

let React = require('react-native');
let {
  AppRegistry,
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
