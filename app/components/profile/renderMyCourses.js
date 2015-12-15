import React, {
  View,
} from 'react-native';

import { activeCourseCard, courseActionCard } from '../courses/coursesCommon';
import Analytics from '../../../modules/Analytics';
import sectionTitle from '../lib/sectionTitle';
import Routes from '../../nav/Routes';
import { SHEET } from '../../CommonStyles';

export default function renderMyCourses({ courses, navigator, isEditable = false }) {
  if (!courses || courses.length == 0) {
    return null;
  }

  const addCourseButton = !isEditable ? null : courseActionCard('Add new course...', () => {
    Analytics.track('Press Add New Course');

    const route = Routes.instance.getAllCoursesListRoute();
    navigator.push(route);
  })

  const isSomeoneElsesProfile = !isEditable;

  return (
    <View style={SHEET.innerContainer}>
      { sectionTitle('COURSES') }
      { courses.map(course => {
        console.log(course);


        course.usersInCourse = [];
        return activeCourseCard(course, false, null, () => {
          Analytics.track('Profile: View Course Details', {
            courseCode: course.courseCode
          });

          const route = Routes.instance.getCourseDetailRoute({
            course,
            renderWithNewNav: isSomeoneElsesProfile // viewing from topnav-less requires new exnav.
          })
          navigator.push(route);
        })
      })}
      { addCourseButton }
    </View>
  );
}
