/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 */
'use strict';

var React = require('react-native');
var ContainerView = require('./ContainerView');
var {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  NativeModules,
  MapView,
} = React;

var mainViewManager = NativeModules.MainViewManager;
mainViewManager.testMethod('Some stuff', 'Some other stuff');


var Taylr = React.createClass({
  render: function() {
    return (<ContainerView sbName='Discover' style={styles.container} />)
    // return (
    //   <View style={styles.container}>
    //     <Text style={styles.welcome}>
    //       This is a far better development flow than most of Code
    //     </Text>
    //     <Text style={styles.instructions}>
    //     Once someone worked out the rough edges, that's where I come in
    //     Pretty sweat
    //     </Text>
    //     <Text style={styles.instructions}>
    //       Press Cmd+R to reload,{'\n'}
    //       Cmd+D or shake for dev menu
    //     </Text>
    //   </View>
    // );
  }
});

var styles = StyleSheet.create({
  container: {
    // width: 667,
    // height: 375,
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});

AppRegistry.registerComponent('SimpleApp', () => Taylr);
