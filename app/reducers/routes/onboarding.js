import LoginScreen from '../../components/onboarding/LoginScreen';

import { combineReducers } from 'redux';

function currentScreen(state = LoginScreen, action) {
  switch (action.type) {
    case 'SHOW_LOGIN_SCREEN':
      return LoginScreen;

    default:
      return state;
  }
}

/**
 * Nav left button reducer
 */
function showLeftNav(state = false, action) {
  switch (action.type) {
    case 'SHOW_LOGIN_SCREEN':
      return false;

    default:
      return state;
  }
}

function showRightNav(state = false, action) {
  return state;
}

module.exports = combineReducers({
  currentScreen,
  nav: combineReducers({
    left: combineReducers({
      show: showLeftNav
    }),

    right: combineReducers({
      show: showRightNav
    })
  })
})
