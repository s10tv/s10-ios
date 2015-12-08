'use strict';

let {
  NativeAppEventEmitter
} = require('react-native');

const logger = new (require('./Logger'))('LayerServiceJs');

class LayerService {
  listen(store) {
    this.unreadListener = NativeAppEventEmitter
      .addListener('Layer.unreadConversationsCountUpdate', (count) => {
        logger.debug(`set unreadConversationsCountUpdate=${count}`)
        store.dispatch({ type: 'CHANGE_UNREAD_COUNT', count: count })
      });

    this.allListener = NativeAppEventEmitter
      .addListener('Layer.allConversationsCountUpdate', (count) => {
        logger.debug(`set allConversationsCountUpdate=${count}`)
        store.dispatch({ type: 'CHANGE_ALL_COUNT', count: count })
      });
  }
}

export default LayerService
