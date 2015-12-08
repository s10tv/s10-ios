import React, {
  NativeModules
} from 'react-native';

import { combineReducers } from 'redux';

const logger = new (require('../../modules/Logger'))('ApphubReducer');
const defaultApphub = Object.assign({}, {
  buildName: 'processing ... ',
}, NativeModules.AppHub);
logger.debug(`defaultApphub=${JSON.stringify(defaultApphub)}`);

function apphub(state = defaultApphub, action) {
  switch(action.type) {
    case 'UPDATE_APPHUB_DETAILS':
      return Object.assign({}, state, action.details);
    default:
      return state;
  }
}

function shouldShowUpgradeCard(state = false, action) {
  switch(action.type) {
    case 'UPDATE_APPHUB_DETAILS':
      return true;

    case 'FINISHED_UPGRADING_APPHUB':
      return false;

    default:
      return state;
  }
}

export {
  apphub,
  shouldShowUpgradeCard,
}
