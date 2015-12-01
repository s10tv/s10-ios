/**
 * @flow
 */
'use strict';


let {
  NativeAppEventEmitter,
  NativeModules: {
    AppHub,
  },
} = require('react-native');

const logger = new (require('../../modules/Logger'))('ApphubService');

class ApphubService {

  constructor(store) {
    logger.debug('apphub service started');
    this.store = store;

    this.allListener = NativeAppEventEmitter
      .addListener('AppHub.newBuild', (details) => {
        logger.debug(`Got new apphub build. details=${JSON.stringify(details)}`)
        store.dispatch({ type: 'UPDATE_APPHUB_DETAILS', details: details })
      });
  }

  static apphub(state = AppHub, action) {
    switch(action.type) {
      case 'UPDATE_APPHUB_DETAILS':
        return Object.assign({}, state, action.details);
      default:
        return state;
    }
  }

  static modalVisible(state = false, action) {
    switch(action.type) {
      case 'HIDE_UPGRADE_POPUP':
        return false
      case 'UPDATE_APPHUB_DETAILS':
      case 'SHOW_HARD_UPGRADE_POPUP':
      case 'SHOW_SOFT_UPGRADE_POPUP':
        return true;
      default:
        return state;
    }
  }

  static hardUpgradeURL(state = null, action) {
    switch(action.type) {
      case 'SHOW_HARD_UPGRADE_POPUP':
        return action.url
      case 'SHOW_SOFT_UPGRADE_POPUP':
        return null;
      default:
        return state;
    }
  }
}

export default ApphubService;
