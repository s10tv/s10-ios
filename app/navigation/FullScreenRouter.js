import BaseRouter from './BaseRouter';

import ConversationScreen from '../components/chat/ConversationScreen';
import ProfileScreen from '../components/profile/ProfileScreen';

import { SCREEN_CONVERSATION, SCREEN_PROFILE } from '../constants'

const ROUTE_MAP = {
  SCREEN_CONVERSATION: ConversationScreen,
  SCREEN_PROFILE: ProfileScreen,
}

/**
 * Router for routing all full screen scenes
 */
class FullScreenRouter extends BaseRouter {

  constructor(nav, dispatch) {
    super(nav, dispatch, 'FULL_SCREEN_ROUTER');

    // Binds this router to routes that it can handle.
    this._routeMap = ROUTE_MAP;
  }

  rightButton(route) {
    return this._rightButton(route, this)
  }

  leftButton(route) {
    return this._leftButton(route, this)
  }

  /**
   * Navigates to the profile speecified by @param userId
   */
  toProfile({ userId }) {
    const id = ProfileScreen.id;
    const props = { userId };

    this.push({ id, props });
  }

  /**
   * Navigates to the conversation screen speecified by @param conversationId
   */
  toConversation({ conversationId }) {
    const id = ConversationScreen.id;
    const props = { conversationId };

    this.push({ id, props });
  }
}

module.exports = FullScreenRouter;
