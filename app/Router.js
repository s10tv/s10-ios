
class Router {
  constructor(nav, dispatch) {
    this.nav = nav;
  }

  _push(id, component, props) {
    this.nav.push({
      id: id,
      component: component,
      props: props,
    })

    this.dispatch({
      type: 'FULL_SCREEN_CURRENT_SCREEN',
      id: id,
      component: component,
      props: props,
    })
  }

  conversationScreen() {

  }
}

module.exports = Router;
