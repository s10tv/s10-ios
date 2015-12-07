import Session from '../../native_modules/Session';

const logger = new (require('../../modules/Logger'))('LoginStatus');

const defaultSession = Session.initialValue();
const defaultLoggedIn = (!!defaultSession && !!defaultSession.resumeToken);

function loggedIn(state = defaultLoggedIn, action) {
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

function isActive(state = true, action) {
  switch (action.type) {
    case 'SET_IS_ACTIVE':
      return action.isActive;
    default:
      return state;
  }
}

function isCWLRequired(state = true, action) {
  switch (action.type) {
    case 'SET_IS_CWL_REQUIRED':
      return action.isCWLRequired;
    default:
      return state;
  }
}

function hasLoggedInThroughCWL(state = false, action) {
  switch (action.type) {
    case 'LOGGED_IN_THROUGH_CWL':
      logger.debug(`setting loggedInThroughCWL to be ${action.loggedInThroughCWL}`);
      return action.loggedInThroughCWL;
    default:
      return false
  }
}

export {
  loggedIn,
  isCWLRequired,
  isActive,
  hasLoggedInThroughCWL,
}
