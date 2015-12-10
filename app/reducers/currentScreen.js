import undoable, { distinctState } from 'redux-undo';
import { SCREEN_TODAY, SCREEN_ME } from '../constants';

const logger = new (require('../../modules/Logger'))('currentscreen');
const defaultTabScreen = { id: 'SCREEN_ME' };

function currentScreen(state = defaultTabScreen, action) {
  switch (action.type) {
    case 'CURRENT_SCREEN':
      return Object.assign({}, state, { id: action.id });

    case 'RESET_CURRENT_SCREEN':
      return defaultTabScreen;

    default:
      return state;
  }
}

module.exports = currentScreen;
