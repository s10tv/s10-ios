import { combineReducers } from 'redux';
import undoable from 'redux-undo';

import loggedIn from './loggedIn';
import routes from './routes/index';
import me from './ddp/me';
import layer from './layer/index';

import { SCREEN_TODAY } from '../constants';

function currentScreen(state = { id: SCREEN_TODAY }, action) {
  switch (action.type) {
    case 'CURRENT_SCREEN':
      return Object.assign({}, state, { id: action.id, props: action.props })
    default:
      return state;
  }
}

exports.currentScreen = undoable(currentScreen);
exports.loggedIn = loggedIn;
exports.routes = routes;
exports.me = me;
exports.layer = layer;
