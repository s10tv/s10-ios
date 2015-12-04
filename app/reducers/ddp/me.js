import Session from '../../../native_modules/Session';

const logger = new (require('../../../modules/Logger'))('MeReducer');

let defaultSession = Session.initialValue() || {};
const defaultMe = Object.assign({}, {
  userId: '',
  firstName: '',
  lastName: '',
  avatarUrl: 'https://s10tv.blob.core.windows.net/s10tv-prod/notfound.jpeg',
  coverUrl: 'https://s10tv.blob.core.windows.net/s10tv-prod/defaultbg.jpg',
  displayName: '',
}, defaultSession);

export default function me(state = defaultMe, action) {
  switch (action.type) {
    case 'SET_ME':
      logger.debug(`in me reducer. got ${action.me}`)
      return Object.assign({}, state, action.me);

    default:
      return state;
  }
}
