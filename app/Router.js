import { ActionCreators } from 'redux-undo';

import ConversationScreen from './components/chat/ConversationScreen';
import ProfileScreen from './components/profile/ProfileScreen';

import HistoryScreen from './components/history/HistoryScreen';

const logger = new (require('../modules/Logger'))('LayerServiceJs');

class Router {
  constructor(nav, dispatch) {
    this.nav = nav;
    this.dispatch = dispatch;
  }

  _push({ id, component, props }) {
    logger.debug(`pushing route id=${id}`);
    this.nav.push({
      id: id,
      component: component,
      props: props,
    })

    this.dispatch({
      type: id,
      component: component,
      props: props,
      router: this,
    })
  }

  pop() {
    this.nav.pop();
    this.dispatch(ActionCreators.undo());
  }

  toHistory() {
    const id = HistoryScreen.id;
    const component = HistoryScreen;
    const props = {};

    this._push({ id, component, props });
  }

  toProfile({ userId }) {
    const id = ProfileScreen.id;
    const component = ProfileScreen;
    const props = { userId };

    this._push({ id, component, props });
  }

  toConversation({ conversationId }) {
    const id = ConversationScreen.id;
    const component = ConversationScreen;
    const props = { conversationId };

    this._push({ id, component, props });
  }
}

module.exports = Router;
