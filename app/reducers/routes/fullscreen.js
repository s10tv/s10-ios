import { combineReducers } from 'redux';

import {
  CURRENT_SCREEN,
  SCREEN_CONVERSATION,
  SCREEN_PROFILE,
  SCREEN_LINK_SERVICE } from '../../constants'

import ProfileScreen from '../../components/profile/ProfileScreen';
import RootNavigator from '../../navigation/RootNavigator';
import ConversationScreen from '../../components/chat/ConversationScreen';

const logger = new (require('../../../modules/Logger'))('fullscreen')

function showLeftNav(state = false, action) {
  switch(action.type) {
    case SCREEN_PROFILE:
      return true;

    default:
      return state;
  }
}

function showRightNav(state = false, action) {
  return state;
}

function navbarHidden(state = true, action) {
  switch (action.type) {
    case CURRENT_SCREEN:
      switch (action.id) {
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

function displayTitle(state = null, action) {
  switch(action.type) {
    case SCREEN_PROFILE:
      return 'Profile'

    default:
      return null;
  }
}

module.exports = combineReducers({
  nav: combineReducers({
    left: combineReducers({
      show: showLeftNav
    }),

    right: combineReducers({
      show: showRightNav
    }),

    displayTitle,
    hidden: navbarHidden,
  })
})
