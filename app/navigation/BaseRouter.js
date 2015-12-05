import React from 'react-native'
import { ActionCreators } from 'redux-undo';

const logger = new (require('../../modules/Logger'))('BaseRouter');

class BaseRouter {

  /**
   * @param nav a React Native {@code Navigator}
   * @param dispatch a Redux dispatch function
   */
  constructor(nav, dispatch) {
    this.nav = nav;
    this.dispatch = dispatch;
  }

  /**
   * @return a component for the left button of the route
   */
  leftButton(route) {
    const Component = this._routeMap[route.id];

    if (!Component) {
      return null;
    }

    return Component.leftButton(route, this);
  }

  /**
   * @return a component for the right button of the route
   */
  rightButton(route) {
    const Component = this._routeMap[route.id];

    if (!Component) {
      return null;
    }

    return Component.rightButton(route, this);
  }

  /**
   * @return a component for the title of the route
   */
  title(route) {
    const Component = this._routeMap[route.id];

    if (!Component) {
      return null;
    }

    return Component.title(route);
  }

  /**
   * @return true if this router can handle the route
   */
  canHandleRoute(route) {
    return !!route && !!route.id && !!this._routeMap[route.id];
  }

  /**
   * @return a component to be rendered given the @param route
   */
  handle(route) {
    const Component = this._routeMap[route.id];

    if (!Component) {
      logger.warning(`trying to handle invalid route id=${route.id}`)
      return;
    }

    return <Component {...route.props} />
  }

  /**
   * pushes a new route onto this router's navigation stack
   */
  push({ id, props }) {
    logger.debug(`will push route id=${id}`);
    this.nav.push({
      id: id,
    })

    this.dispatch({
      type: 'CURRENT_SCREEN',
      id: id,
      props: props
    })
  }

  /**
   * removes a route from this router's navigation stack.
   */
  pop() {
    logger.debug(`will pop route`);
    this.nav.pop();
    this.dispatch(ActionCreators.undo());
  }
}

module.exports = BaseRouter;
