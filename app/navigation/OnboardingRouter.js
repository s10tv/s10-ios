import BaseRouter from './BaseRouter';

import LoginScreen from '../components/onboarding/LoginScreen';
import JoinNetworkScreen from '../components/onboarding/JoinNetworkScreen';
import LinkServiceScreen from '../components/onboarding/LinkServiceScreen';

import {
  SCREEN_OB_LOGIN,
} from '../constants';

const logger = new (require('../../modules/Logger'))('OnboardingRouter');
const ROUTE_MAP = {
  SCREEN_OB_LOGIN: LoginScreen,
  SCREEN_OB_CWL: JoinNetworkScreen,
  SCREEN_OB_LINK_SERVICE: LinkServiceScreen,
  SCREEN_OB_CREATE_PROFILE: LoginScreen,
  SCREEN_OB_CREATE_HASHTAG: LoginScreen,
};

/**
 * Router for routing all onboarding scenes
 */
class OnboardingRouter extends BaseRouter {

  constructor(nav, dispatch) {
    super(nav, dispatch);

    // Binds this router to routes that it can handle.
    this._routeMap = ROUTE_MAP;
  }

  rightButton(route) {
    return this._rightButton(route, this)
  }

  leftButton(route) {
    return this._leftButton(route, this)
  }

  toJoinNetworkScreen() {
    const id = JoinNetworkScreen.id;
    const props = {};

    this.push({ id, props })
  }

  toLinkServiceScreen() {
    const id = LinkServiceScreen.id;
    const props = {};

    this.push({ id, props })
  }
}

module.exports = OnboardingRouter;
