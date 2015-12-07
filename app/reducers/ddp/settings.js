const logger = new (require('../../../modules/Logger'))('SettingsReducer');

export default function myTags(state = {}, action) {
  switch (action.type) {
    case 'SET_SETTINGS':
      return Object.assign({}, state, action.setings);

    default:
      return state;
  }
}
