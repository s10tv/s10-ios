import { combineReducers } from 'redux';

import {
  CURRENT_SCREEN,
  SCREEN_CONVERSATION,
  SCREEN_PROFILE,
  SCREEN_LINK_SERVICE,
  SCREEN_OB_LINK_ONE_SERVICE,
} from '../../constants'

const logger = new (require('../../../modules/Logger'))('fullscreen')

function navbarHidden(state = true, action) {
  switch (action.type) {
    case CURRENT_SCREEN:
      switch (action.id) {
        case SCREEN_OB_LINK_ONE_SERVICE:
        case SCREEN_CONVERSATION:
          return true;

        case SCREEN_LINK_SERVICE:
        case SCREEN_PROFILE:
          return false;
      }

    default:
      return true;
  }
}

module.exports = combineReducers({
  nav: combineReducers({
    hidden: navbarHidden,
  })
})
