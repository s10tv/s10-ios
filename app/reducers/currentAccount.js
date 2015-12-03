import Session from '../../native_modules/Session';

export default function currentAccount(state = Session.initialValue, action) {
  switch(action.type) {
    case 'LOGOUT':
      return null;

    default:
      return state;
  }
}
