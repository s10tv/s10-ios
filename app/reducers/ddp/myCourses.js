const logger = new (require('../../../modules/Logger'))('MyCoursesReducer');
const defaultCourses = { loaded: false, loadedCourses: [] };

export default function myCourses(state = defaultCourses, action) {
  switch (action.type) {
    case 'SET_MY_COURSES':
      return Object.assign({}, state, {
        loadedCourses: action.mycourses,
        loaded: true
      });
      // TODO(qimingfang): better merge these arrays using Array.reduce.

    case 'LOGOUT':
      return defaultCourses;

    default:
      return state;
  }
}
