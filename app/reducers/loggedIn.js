import Session from '../../native_modules/Session';

export default function loggedIn(state = !!Session.initialValue, action) {
  switch(action.type) {
    case 'LOGIN_FROM_FB':
    case 'LOGIN_FROM_DIGITS':
    case 'LOGIN_FROM_RESUME':
      return true;

    case 'LOGOUT':
      return false;

    default:
      return state;
  }
}
