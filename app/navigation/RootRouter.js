import BaseRouter from './BaseRouter';

import DiscoverScreen from '../components/discover/DiscoverScreen';
import MeScreen from '../components/me/MeScreen';
import EditProfileScreen from '../components/editprofile/EditProfileScreen';
import ChatListView from '../components/chat/ConversationListView';
import HistoryScreen from '../components/history/HistoryScreen';
import CategoryListScreen from '../components/categorylist/CategoryListScreen';
import TabNavigatorScreen from './TabNavigatorScreen';

import {
  SCREEN_CONVERSATION_LIST,
  SCREEN_ME,
  SCREEN_TODAY,
  SCREEN_HISTORY,
} from '../constants';

const ROUTE_MAP = {
  SCREEN_CONVERSATION_LIST: TabNavigatorScreen,
  SCREEN_ME: TabNavigatorScreen,
  SCREEN_TODAY: TabNavigatorScreen,
  SCREEN_HISTORY: HistoryScreen,
  SCREEN_EDIT_PROFILE: EditProfileScreen,
  SCREEN_CATEGORY_LIST: CategoryListScreen,
}

/**
 * Router for routing all Nav-Tab related scenes (scenes with a navigator bar).
 */
class RootRouter extends BaseRouter {

  constructor(nav, dispatch) {
    super(nav, dispatch, 'ROOT_ROUTER');

    // Binds this router to routes that it can handle.
    this._routeMap = ROUTE_MAP;
  }

  rightButton(route) {
    return this._rightButton(route, this)
  }

  leftButton(route) {
    return this._leftButton(route, this)
  }

  toHistory() {
    const id = HistoryScreen.id;
    const props = {};

    this.push({ id, props });
  }

  toEditProfile() {
    const id = EditProfileScreen.id;
    const props = {};

    this.push({ id, props });
  }

  toCategoryList({ category }) {
    const id = CategoryListScreen.id;
    const props = { category };

    this.push({ id, props });
  }
}

module.exports = RootRouter;
