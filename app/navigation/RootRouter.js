import BaseRouter from './BaseRouter';

import DiscoverScreen from '../components/discover/DiscoverScreen';
import MeScreen from '../components/me/MeScreen';
import ChatListView from '../components/chat/ConversationListView';
import TabNavigatorScreen from './TabNavigatorScreen';;

import { SCREEN_CONVERSATION_LIST, SCREEN_ME, SCREEN_TODAY } from '../constants'

const ROUTE_MAP = {
  SCREEN_CONVERSATION_LIST: TabNavigatorScreen,
  SCREEN_ME: TabNavigatorScreen,
  SCREEN_TODAY: TabNavigatorScreen,
}

/**
 * Router for routing all Nav-Tab related scenes (scenes with a navigator bar).
 */
class RootRouter extends BaseRouter {

  constructor(nav, dispatch) {
    super(nav, dispatch);

    // Binds this router to routes that it can handle.
    this._routeMap = ROUTE_MAP;
  }

}

module.exports = RootRouter;
