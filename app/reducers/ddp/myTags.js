const logger = new (require('../../../modules/Logger'))('MyTagsReducer');

export default function myTags(state = [], action) {
  switch (action.type) {
    case 'SET_MY_TAGS':

      // TODO(qimingfang): better merge these arrays using Array.reduce.
      return action.mytags;

    case 'LOGOUT':
      return [];

    default:
      return state;
  }
}
