const logger = new (require('../../../modules/Logger'))('MyCoursesReducer');

export default function myCourses(state = { loaded: false, loadedCourses: [] }, action) {
  switch (action.type) {
    case 'SET_MY_COURSES':
      return Object.assign({}, state, {
        loadedCourses: action.mycourses,
        loaded: true
      });
      // TODO(qimingfang): better merge these arrays using Array.reduce.

    default:
      return state;
  }
}
