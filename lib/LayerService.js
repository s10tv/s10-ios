/**
 * @flow
 */
'use strict';

import { createStore } from 'redux'
let {
  NativeAppEventEmitter,
  NativeModules: {
    TSLayerService,
  },
} = require('react-native');

const logger = new (require('./Logger'))('LayerServiceJs');

class LayerService {
  constructor() {
    this.store = createStore(this.reduceFn);

    this.unreadListener = NativeAppEventEmitter
      .addListener('Layer.unreadConversationsCountUpdate', (count) => {
        this.store.dispatch({ type: 'CHANGE_UNREAD_COUNT', count: count })
      });

    this.allListener = NativeAppEventEmitter
      .addListener('Layer.allConversationsCountUpdate', (count) => {
        this.store.dispatch({ type: 'CHANGE_ALL_COUNT', count: count })
      });
  }

  reduceFn(state = { unreadCount: 0, unreadCount: 0}, action) {
    switch (action.type) {
      case 'CHANGE_UNREAD_COUNT':
        return Object.assign({}, state, {
          unreadCount: action.count
        });
      case 'CHANGE_ALL_COUNT':
        return Object.assign({}, state, {
          allCount: action.count
        });
      default:
        return state;
    } 
  }
}

module.exports = LayerService;