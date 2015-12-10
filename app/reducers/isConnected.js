function isConnected(state = true, action) {
  switch(action.type) {
    case 'CHANGE_IS_CONNECTED':
      return action.isConnected

    default:
      return state;
  }
}

function shouldShowNetworkBanner(state = false, action) {
  switch(action.type) {
    case 'SHOW_BANNER':
      return true

    case 'HIDE_BANNER':
      return false;

    default:
      return state;
  }
}

export {
  isConnected,
  shouldShowNetworkBanner,
}
