import BaseRouter from './BaseRouter';

import LoginScreen from '../components/onboarding/LoginScreen';
import JoinNetworkScreen from '../components/onboarding/JoinNetworkScreen';
import CampusWideLoginScreen from '../components/onboarding/CampusWideLoginScreen';
import LinkServiceScreen from '../components/onboarding/LinkServiceScreen';
import LinkServiceWebView from '../components/linkservice/LinkServiceScreen';

import {
  SCREEN_OB_LOGIN,
  SCREEN_OB_CWL,
  SCREEN_OB_CWL_LOGIN,
  SCREEN_OB_LINK_SERVICE,
  SCREEN_OB_CREATE_PROFILE,
  SCREEN_OB_CREATE_HASHTAG,
  SCREEN_LINK_SERVICE,
  SCREEN_OB_LINK_ONE_SERVICE,
} from '../constants';

const logger = new (require('../../modules/Logger'))('OnboardingRouter');
const ROUTE_MAP = {
  SCREEN_OB_LOGIN: LoginScreen,
  SCREEN_OB_CWL: JoinNetworkScreen,
  SCREEN_OB_CWL_LOGIN: CampusWideLoginScreen,
  SCREEN_OB_LINK_SERVICE: LinkServiceScreen,
  SCREEN_OB_CREATE_PROFILE: LoginScreen,
  SCREEN_OB_CREATE_HASHTAG: LoginScreen,
  SCREEN_OB_LINK_ONE_SERVICE: LinkServiceWebView,
};

/**
 * Router for routing all onboarding scenes
 */
class OnboardingRouter extends BaseRouter {

  constructor(nav, dispatch) {
    super(nav, dispatch, 'ONBOARDING_ROUTER');

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

  toCWLLoginScreen() {
    const id = CampusWideLoginScreen.id;
    const props = {};

    this.push({ id, props })
  }

  toLinkServiceScreen() {
    const id = LinkServiceScreen.id;
    const props = {};

    this.push({ id, props })
  }

  /**
   * Navigates to a screen to a screen with a special webview (that closes on taylr-dev://)
   * for linking services.
   */
   toLinkWebView({ url, onServiceLinkNavStateChange }) {
     const props = { url, onServiceLinkNavStateChange };

     this.push({ id: 'SCREEN_OB_LINK_ONE_SERVICE' , props });
   }
}

module.exports = OnboardingRouter;
