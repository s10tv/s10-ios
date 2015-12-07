import { combineReducers } from 'redux';

import {
  CURRENT_SCREEN,
  SCREEN_OB_CWL,
  SCREEN_OB_CREATE_PROFILE,
  SCREEN_OB_LINK_SERVICE,
  SCREEN_OB_CREATE_HASHTAG,
} from '../../constants'

const logger = new (require('../../../modules/Logger'))('fullscreen')

function navHidden(state = true, action) {
  switch (action.type) {
    case CURRENT_SCREEN:
      switch (action.id) {
        case SCREEN_OB_CWL:
        case SCREEN_OB_CREATE_PROFILE:
        case SCREEN_OB_LINK_SERVICE:
        case SCREEN_OB_CREATE_HASHTAG:
          return false;
      }

    default:
      return true;
  }
}

module.exports = combineReducers({
  nav: combineReducers({
    hidden: navHidden
  })
})
