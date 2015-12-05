import BaseRouter from './BaseRouter';

import DiscoverScreen from '../components/discover/DiscoverScreen';
import MeScreen from '../components/me/MeScreen';
import ChatListView from '../components/chat/ConversationListView';

import {
  SCREEN_CONVERSATION_LIST,
  SCREEN_ME,
  SCREEN_TODAY,
} from '../constants';

const logger = new (require('../../modules/Logger'))('TabRouter');
const ROUTE_MAP = {
  SCREEN_CONVERSATION_LIST: ChatListView,
  SCREEN_ME: MeScreen,
  SCREEN_TODAY: DiscoverScreen,
}

/**
 * Router for routing all Nav-Tab related scenes (scenes with a navigator bar).
 */
class TabRouter extends BaseRouter {

  constructor(nav, dispatch) {
    super(nav, dispatch);

    // Binds this router to routes that it can handle.
    this._routeMap = ROUTE_MAP;
  }

  rightButton(route, router) {
    return this._rightButton(route, router)
  }

  leftButton(route, router) {
    return this._leftButton(route, router)
  }
}

module.exports = TabRouter;
