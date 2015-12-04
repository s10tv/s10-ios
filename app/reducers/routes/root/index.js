import DiscoverScreen from '../../../components/discover/DiscoverScreen';

import { combineReducers } from 'redux';

function currentScreen(state = DiscoverScreen, action) {
  switch (action.type) {
    case 'SHOW_DISCOVER_SCREEN':
      return DiscoverScreen;

    default:
      return state;
  }
}

/**
 * Nav left button reducer
 */
function showLeftNav(state = false, action) {
  switch (action.type) {
    case 'SHOW_DISCOVER_SCREEN':
      return true;

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
