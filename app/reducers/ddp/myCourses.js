const logger = new (require('../../../modules/Logger'))('MyCoursesReducer');

export default function myCourses(state = [], action) {
  switch (action.type) {
    case 'SET_MY_COURSES':

      // TODO(qimingfang): better merge these arrays using Array.reduce.
      return action.mycourses;

    default:
      return state;
  }
}
