import undoable, { distinctState } from 'redux-undo';

const logger = new (require('../../modules/Logger'))('currentscreen');
const defaultTabScreen = { id: 'SCREEN_EVENTS' };

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
