import undoable, { distinctState } from 'redux-undo';
import { SCREEN_TODAY, SCREEN_ME } from '../constants';

const logger = new (require('../../modules/Logger'))('currentscreen');

function currentScreen(state = { id: 'SCREEN_TODAY' }, action) {
  switch (action.type) {
    case 'CURRENT_SCREEN':
      const screen = Object.assign({}, state, { id: action.id, props: action.props });
      logger.debug(`currentSCreen=${JSON.stringify(screen)}`)
      return screen;
    default:
      return state;
  }
}

module.exports = undoable(currentScreen, { filter: distinctState() });
