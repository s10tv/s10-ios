import Session from '../../native_modules/Session';

const logger = new (require('../../modules/Logger'))('Session.js');

const defaultSession = Session.initialValue();
const defaultLoggedIn = (!!defaultSession && !!defaultSession.resumeToken);

export default function loggedIn(state = defaultLoggedIn, action) {
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
