const logger = new (require('../../../modules/Logger'))('MyTagsReducer');

export default function myCheckins(state = [], action) {
  switch (action.type) {
    case 'SET_MY_CHECKINS':

      // TODO(qimingfang): better merge these arrays using Array.reduce.
      return action.checkins;

    default:
      return state;
  }
}
