import React from 'react-native'
import { ActionCreators } from 'redux-undo';

const logger = new (require('../../modules/Logger'))('BaseRouter');

class BaseRouter {

  /**
   * @param nav a React Native {@code Navigator}
   * @param dispatch a Redux dispatch function
   */
  constructor(nav, dispatch, id) {
    this.nav = nav;
    this.dispatch = dispatch;
    this.id = id;
  }

  /**
   * @return a component for the left button of the route
   */
  _leftButton(route, router) {
    const Component = this._routeMap[route.id];

    if (!Component) {
      return null;
    }

    return Component.leftButton(route, router);
  }

  /**
   * @return a component for the right button of the route
   */
  _rightButton(route, router) {
    const Component = this._routeMap[route.id];

    if (!Component) {
      return null;
    }

    return Component.rightButton(route, router);
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
  handle(route, extraProps = {}) {
    logger.info(`handling route=${JSON.stringify(route)}`)
    const Component = this._routeMap[route.id];

    if (!Component) {
      logger.warning(`trying to handle invalid route id=${route.id}`)
      return;
    }

    const props = Object.assign({}, route.props, extraProps);

    return <Component {...props} />
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
