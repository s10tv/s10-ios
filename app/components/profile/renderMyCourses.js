import React, {
  View,
  AlertIOS,
} from 'react-native';

import { activeCourseCard, courseActionCard } from '../courses/coursesCommon';
import Analytics from '../../../modules/Analytics';
import sectionTitle from '../lib/sectionTitle';
import Routes from '../../nav/Routes';
import { SHEET } from '../../CommonStyles';

function removeCourse(course, onRemoveCourse) {
  AlertIOS.alert(
    'Remove Course',
    'Do you really want to remove this course?',
    [
      // Delete Button
      {text: 'Delete', onPress: () => {
        Analytics.track('My Courses: Remove Course', {
          courseCode: course.courseCode
        });
        onRemoveCourse(course._id)
      }, style: 'destructive'},

      // Cancel Button
      {text: 'Cancel', style: 'cancel'}
    ]
  )
}

export default function renderMyCourses({ courses, navigator, onRemoveCourse, isEditable = false }) {
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
        course.usersInCourse = [];
        return activeCourseCard(
          course,
          isEditable,
          isEditable ? () => removeCourse(course, onRemoveCourse) : null,
          () => {
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
