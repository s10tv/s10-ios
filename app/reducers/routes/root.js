import DiscoverScreen from '../../components/discover/DiscoverScreen';
import TabNavigatorScreen from '../../components/TabNavigatorScreen';

import { combineReducers } from 'redux';

function currentScreen(state = TabNavigatorScreen, action) {
  switch (action.type) {
    case 'SHOW_DISCOVER_SCREEN':
      return DiscoverScreen;

    default:
      return state;
  }
}

function currentTab(state = 'Today', action) {
  switch(action.type) {
    case 'SWITCH_BASE_TAB':
      const tab = action.currentTab;
      switch(tab) {
        case 'Today': // fallthrough intentional
        case 'Conversations':
        case 'Me':
          return tab;
      }
    default: // fallthrough intentional
      return state
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
  currentTab,
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
