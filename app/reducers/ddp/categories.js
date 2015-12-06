const logger = new (require('../../../modules/Logger'))('categoriesReducer');

export default function categories(state = [], action) {
  switch (action.type) {
    case 'SET_TAG_CATEGORIES':

      // TODO(qimingfang): better merge these arrays using Array.reduce.
      return action.categories;

    default:
      return state;
  }
}
