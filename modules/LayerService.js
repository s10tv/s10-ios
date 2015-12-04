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

    this.navigateToConversationViewListener = NativeAppEventEmitter
      .addListener('Navigation.push', (properties) => {
        logger.debug('did receive Navigation.push')
        switch (properties.routeId) {
          case 'conversation':
            store.dispatch({
              type: 'CONVERSATION_SCREEN',
              props: { conversationId: properties.args.conversationId },
            })
            break;
          case 'profile':
            store.dispatch({
              type: 'PROFILE_SCREEN',
            })
            break;
        }
    });

    this.popListener = NativeAppEventEmitter
      .addListener('Navigation.pop', (properties) => {
        logger.debug('did receive Navigation.pop')
        store.dispatch({
          type: 'PRESSED_BACK_FROM_CONVERSATION',
        })
      });
  }
}

export { LayerService }
