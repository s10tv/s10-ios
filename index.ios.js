'use strict';

// polyfill the process functionality needed
global.process = require("./lib/process.polyfill");

import React, {
  AppRegistry,
} from 'react-native';

import thunk from 'redux-thunk';
import { createStore, combineReducers, applyMiddleware } from 'redux';
import { Provider } from 'react-redux/native';

import TSDDPClient from './lib/ddpclient';
import ApphubService from './lib/ApphubService';
import PushHandler from './lib/PushHandler';
import BridgeManager from './modules/BridgeManager';
import LayerService from './modules/LayerService';
import LayoutContainer from './app/LayoutContainer';
import DDPService from './app/lib/ddp';

import * as reducers from './app/reducers'

const logger = new (require('./modules/Logger'))('index.ios');

logger.info(`JS App Launched. bundle url=${BridgeManager.bundleUrlScheme()}`);

const ddpClient = new DDPService(BridgeManager.serverUrl());

let createStoreWithMiddleware = applyMiddleware(
  thunk
)(createStore);

let store = createStoreWithMiddleware(combineReducers({
  ...reducers,
  ddp: () => ddpClient, // keep ddp in global state for use later.
}))

new LayerService().listen(store);
new ApphubService().listen(store);
new PushHandler().listen(store, ddpClient);

BridgeManager.registerForPushNotifications();

const deviceId = BridgeManager.deviceId();
const deviceOptions = {};
deviceOptions.appId = BridgeManager.appId();
deviceOptions.version = BridgeManager.version();
deviceOptions.build = BridgeManager.build();
deviceOptions.deviceName = BridgeManager.deviceName();
ddpClient.call({ methodName: 'connectDevice', params: [deviceId, deviceOptions]});

class Main extends React.Component {
  render() {
    return (
      <Provider store={store}>
        {() => <LayoutContainer ddp={ddpClient} />}
      </Provider>
    )
  }
}

AppRegistry.registerComponent('Taylr', () => Main);
