import React from 'react-native'

import DiscoverScreen from './components/discover/DiscoverScreen';
import MeScreen from './components/me/MeScreen';
import ChatListView from './components/chat/ConversationListView';
import TabNavigatorScreen from './components/TabNavigatorScreen';

import { combineReducers } from 'redux';
import { SCREEN_CONVERSATION_LIST, SCREEN_ME, SCREEN_TODAY } from './constants'

const logger = new (require('../modules/Logger'))('RootRouter');


class RootRouter {

  static _routeMap = Object.assign({}, {
    SCREEN_CONVERSATION_LIST: TabNavigatorScreen,
    SCREEN_ME: TabNavigatorScreen,
    SCREEN_TODAY: TabNavigatorScreen,
  });

  constructor(nav, dispatch) {
    this.nav = nav;
    this.dispatch = dispatch;
  }

  _generateRouteMap(screens) {
    const routes = {};
    screens.forEach(component=> {
      routes[component.id] = component;
    })
    return routes;
  }

  _push({ id, component, props }) {
    logger.debug(`pushing route id=${id}`);
    this.nav.push({
      id: id,
      props: props,
    })

    this.dispatch({
      type: 'CURRENT_SCREEN',
      id: id,
    })
  }

  canHandleRoute(route) {
    return !! route && !!route.id && !!RootRouter._routeMap[route.id];
  }

  static leftButton(route) {
    const Component = RootRouter._routeMap[route.id];

    if (!Component) {
      return null;
    }

    return Component.leftButton(route);
  }

  static rightButton(route) {
    const Component = RootRouter._routeMap[route.id];

    if (!Component) {
      return null;
    }

    return Component.rightButton(route);
  }

  static title(route) {
    const Component = RootRouter._routeMap[route.id];

    if (!Component) {
      return null;
    }

    return Component.title(route);
  }

  handle(route) {
    const Component = RootRouter._routeMap[route.id];

    if (!Component) {
      logger.warning(`trying to handle invalid route id=${route.id}`)
      return;
    }

    return <Component {...route.props} />
  }
}

module.exports = RootRouter;
