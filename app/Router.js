import React from 'react-native'
import { ActionCreators } from 'redux-undo';

import ConversationScreen from './components/chat/ConversationScreen';
import ProfileScreen from './components/profile/ProfileScreen';

import HistoryScreen from './components/history/HistoryScreen';
import { SCREEN_CONVERSATION, SCREEN_PROFILE } from './constants'

const logger = new (require('../modules/Logger'))('Router');

class Router {
  static _routeMap = {
    SCREEN_CONVERSATION: ConversationScreen,
    SCREEN_PROFILE: ProfileScreen,
  }

  constructor(nav, dispatch) {
    this.nav = nav;
    this.dispatch = dispatch;
  }

  _push({ id, props }) {
    logger.debug(`pushing route id=${id} props=${props}`);
    this.nav.push({
      id: id,
    })

    this.dispatch({
      type: 'CURRENT_SCREEN',
      id: id,
      props: props
    })
  }

  static leftButton(route, router) {
    const Component = Router._routeMap[route.id];

    if (!Component) {
      return null;
    }

    return Component.leftButton(route, router);
  }

  static rightButton(route, router) {
    const Component = Router._routeMap[route.id];

    if (!Component) {
      return null;
    }

    return Component.rightButton(route, router);
  }

  static title(route) {
    const Component = Router._routeMap[route.id];

    if (!Component) {
      return null;
    }

    return Component.title(route);
  }

  canHandleRoute(route) {
    return !! route && !!route.id && !!Router._routeMap[route.id];
  }

  handle(route) {
    const Component = Router._routeMap[route.id];

    if (!Component) {
      logger.warning(`trying to handle invalid route id=${route.id}`)
      return;
    }

    return <Component {...route.props} />
  }

  pop() {
    logger.debug(`will pop route`);
    this.nav.pop();
    this.dispatch(ActionCreators.undo());
  }

  toProfile({ userId }) {
    const id = ProfileScreen.id;
    const props = { userId };

    this._push({ id, props });
  }

  toConversation({ conversationId }) {
    const id = ConversationScreen.id;
    const props = { conversationId };

    this._push({ id, props });
  }
}

module.exports = Router;
