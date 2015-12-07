import undoable, { distinctState } from 'redux-undo';
import { combineReducers } from 'redux';

import {
  CURRENT_SCREEN,
  SCREEN_OB_LOGIN,
  SCREEN_OB_CWL,
  SCREEN_OB_CWL_LOGIN,
  SCREEN_OB_CREATE_PROFILE,
  SCREEN_OB_LINK_SERVICE,
  SCREEN_OB_CREATE_HASHTAG,
  SCREEN_LINK_SERVICE,
  SCREEN_OB_LINK_ONE_SERVICE,
} from '../../constants'

const logger = new (require('../../../modules/Logger'))('fullscreen')

function navHidden(state = true, action) {
  switch (action.type) {
    case CURRENT_SCREEN:
      logger.info(`figuring out if navbar is hidden=${JSON.stringify(action)}`)
      switch (action.id) {
        case SCREEN_OB_CWL:
        case SCREEN_OB_CWL_LOGIN:
        case SCREEN_OB_CREATE_PROFILE:
        case SCREEN_OB_LINK_SERVICE:
        case SCREEN_OB_LINK_ONE_SERVICE:
        case SCREEN_OB_CREATE_HASHTAG:
          return false;

        case SCREEN_OB_LOGIN:
          return true;
      }

    default:
      return state;
  }
}

module.exports = combineReducers({
  nav: combineReducers({
    hidden: undoable(navHidden)
  })
})
