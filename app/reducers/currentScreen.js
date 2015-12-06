import undoable from 'redux-undo';
import { SCREEN_TODAY, SCREEN_ME } from '../constants';

function currentScreen(state = { id: 'SCREEN_TODAY' }, action) {
  switch (action.type) {
    case 'CURRENT_SCREEN':
      return Object.assign({}, state, { id: action.id, props: action.props })
    default:
      return state;
  }
}

module.exports = undoable(currentScreen);
