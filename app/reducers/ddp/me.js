import Session from '../../../native_modules/Session';

const logger = new (require('../../../modules/Logger'))('MeReducer');

let defaultSession = Session.initialValue() || {};

logger.info(`default session=${JSON.stringify(defaultSession)}`)

const defaultUser = {
  userId: '',
  firstName: '',
  lastName: '',
  avatarUrl: 'https://s10tv.blob.core.windows.net/s10tv-prod/notfound.jpeg',
  coverUrl: 'https://s10tv.blob.core.windows.net/s10tv-prod/defaultbg.jpg',
  gradYear: '',
  shortDisplayName: '',
  displayName: '',
  connectedProfiles: [],
};

const defaultMe = Object.assign({}, defaultUser, defaultSession);

export default function me(state = defaultMe, action) {
  switch (action.type) {
    case 'SET_ME':
      return Object.assign({}, state, action.me);

    case 'LOGOUT':
      return defaultUser;

    default:
      return state;
  }
}
