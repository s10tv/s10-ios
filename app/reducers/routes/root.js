import DiscoverScreen from '../../components/discover/DiscoverScreen';
import TabNavigatorScreen from '../../navigation/TabNavigatorScreen';

import { combineReducers } from 'redux';

import { SWITCH_BASE_TAB, SCREEN_HISTORY } from '../../constants'

function currentTab(state = 'Today', action) {
  switch(action.type) {
    case SWITCH_BASE_TAB:
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

function showLeftNav(state = false, action) {
  switch (action.type) {
    case 'SHOW_DISCOVER_SCREEN':
      return true;

    default:
      return state;
  }
}

function rightNav(state = { show: true, action: null, text: 'History' }, action) {
  switch (action.type) {
    case SWITCH_BASE_TAB:
      const tab = action.currentTab;
      switch(tab) {
        case 'Today': // fallthrough intentional
          return state;
          /*
          return Object.assign({}, state, {
            show: true,
            text: 'History',
            onClick: action.router.toHistory,
          })
          */
      }

    default:
      return state;
  }
}

module.exports = combineReducers({
  currentTab,
  nav: combineReducers({
    left: combineReducers({
      show: showLeftNav
    }),

    right: rightNav,
  })
})
