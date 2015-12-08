import undoable, { distinctState } from 'redux-undo';
import { SCREEN_TODAY, SCREEN_ME } from '../constants';

const logger = new (require('../../modules/Logger'))('currentscreen');

function currentScreen(state = { id: 'SCREEN_TODAY' }, action) {
  switch (action.type) {
    case 'CURRENT_SCREEN':
      logger.debug(`currentScreen action=${JSON.stringify(action)}`)
      const screen = Object.assign({}, state, { id: action.id, props: action.props });
      logger.debug(`currentScreen=${JSON.stringify(screen)}`)
      return screen;
    default:
      return state;
  }
}

module.exports = currentScreen;
