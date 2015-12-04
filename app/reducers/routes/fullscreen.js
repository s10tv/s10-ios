import { combineReducers } from 'redux';

import ProfileScreen from '../../components/profile/ProfileScreen';
import RootNavigator from '../../RootNavigator';
import ConversationScreen from '../../components/chat/ConversationScreen';

const logger = new (require('../../../modules/Logger'))('fullscreen')

function currentScreen(state = RootNavigator, action) {
  switch (action.type) {
    case 'PROFILE_SCREEN':
      return ProfileScreen;

    case 'CONVERSATION_SCREEN':
      return ConversationScreen;

    case 'DISCOVER_SCREEN':
    case 'HISTORY_SCREEN':
    case 'ME_SCREEN':
    case 'ME_EDIT_SCREEN':
    case 'CONVERSATION_LIST':
      return RootNavigator;

    default:
      return state;
  }
}

function showLeftNav(state = false, action) {
  return state;
}

function showRightNav(state = false, action) {
  return state;
}

function currentProps(state = {}, action) {
  switch (action.type) {
    case 'CONVERSATION_SCREEN':
      logger.debug(`got CONVERSATION_SCREEN. props:${JSON.stringify(action.props)}`);
      return Object.assign({}, state, action.props);
    default:
      return state;
  }
}

function didPressBack(state = false, action) {
  switch (action.type) {
    case 'PRESSED_BACK_FROM_CONVERSATION':
      return true;

    default:
      return false;
  }
}

function didPressNext(state = false, action) {
  case 'PROFILE_SCREEN':
    return ProfileScreen;

  case 'CONVERSATION_SCREEN':
    return ConversationScreen;

  case 'DISCOVER_SCREEN':
  case 'HISTORY_SCREEN':
  case 'ME_SCREEN':
  case 'ME_EDIT_SCREEN':
  case 'CONVERSATION_LIST':
}

function navbarHidden(state = false, action) {
  switch (action.type) {
    case 'CONVERSATION_SCREEN':
      return true;

    default:
      return state;
  }
}

const defaultTransition = { didPressNext: false, nextRouteId: '' };
function transition(state = defaultTransition, action) {
  switch (action.type) {
    case 'CONVERSATION_LIST_TO_CONVERSATION_SCREEN':
      return Object.assign({}, state, { didPressNext: true, nextRouteId: 'conversation' })

    default:
      return defaultTransition;
  }
}

module.exports = combineReducers({
  didPressBack,
  currentScreen,
  currentProps,
  transition,
  nav: combineReducers({
    left: combineReducers({
      show: showLeftNav
    }),

    right: combineReducers({
      show: showRightNav
    }),

    hidden: navbarHidden,
  })
})
