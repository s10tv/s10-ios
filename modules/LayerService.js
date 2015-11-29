/**
 * @flow
 */
'use strict';


let {
  NativeAppEventEmitter,
  NativeModules: {
    TSLayerService,
  },
} = require('react-native');

const logger = new (require('./Logger'))('LayerServiceJs');

class LayerService {
  constructor(store) {
    this.unreadListener = NativeAppEventEmitter
      .addListener('Layer.unreadConversationsCountUpdate', (count) => {
        store.dispatch({ type: 'CHANGE_UNREAD_COUNT', count: count })
      });

    this.allListener = NativeAppEventEmitter
      .addListener('Layer.allConversationsCountUpdate', (count) => {
        store.dispatch({ type: 'CHANGE_ALL_COUNT', count: count })
      });
  }

  static allConversationCount(state = 0 , action) {
    switch (action.type) {
      case 'CHANGE_ALL_COUNT':
        return action.count
      default:
        return state;
    }
  }

  static unreadConversationCount(state = 0 , action) {
    switch (action.type) {
      case 'CHANGE_UNREAD_COUNT':
        action.count
      default:
        return state;
    }
  }
}

export { LayerService }