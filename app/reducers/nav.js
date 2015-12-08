
function showNavBar(state = false, action) {
  switch (action) {
    case 'HIDE_NAV_BAR':
      return false;

    case 'SHOW_NAV_BAR':
      return true;

    default:
      return state;
  }
}

export {
  showNavBar
}
