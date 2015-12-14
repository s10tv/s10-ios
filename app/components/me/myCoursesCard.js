import React, {
  Text,
  TouchableOpacity,
  View,
  StyleSheet,
  Image
} from 'react-native';

import { TappableCard } from '../lib/Card';
import Loader from '../lib/Loader';
import { SHEET, COLORS } from '../../CommonStyles'
import Routes from '../../nav/Routes'
import { formatCourse, courseActionCard } from '../courses/coursesCommon';
import Analytics from '../../../modules/Analytics';
const logger = new (require('../../../modules/Logger'))('myCoursesCard');

function renderCourses(courses, navigator) {
  if (!courses.loaded) {
    return (<Loader />)
  }

  if (courses.loaded && courses.loadedCourses.length == 0) {
    return courseActionCard('Add new course...', () => {
      Analytics.track('Me: Press Add New Course');
      const route = Routes.instance.getAllCoursesListRoute();
      navigator.push(route);
    })
  }

  return (
    <TappableCard
      style={styles.card}
      onPress={(event) => {
        Analytics.track('Me: View My Courses');
        const route = Routes.instance.getMyCoursesListRoute(courses);
        navigator.push(route);
      }}>
      <View style={styles.courseContainer}>
        {courses.loadedCourses.map(course => { return renderCourseTag(course) })}
      </View>
    </TappableCard>
  )
}

function renderCourseTag(course) {
  return (
    <View style={styles.courseTag} key={course._id}>
      <Image
        style={styles.courseTagIcon}
        source={require('../img/ic-class-icon.png')}
        />
      <Text style={[SHEET.baseText, styles.courseTagText]}>{formatCourse(course.dept, course.course)}</Text>
    </View>
  )
}

var styles = StyleSheet.create({
  card: {
    borderRadius: 3,
  },
  courseContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginHorizontal: -8,
    marginVertical: -5,
    alignItems: 'flex-start',
  },
  courseTag: {
    backgroundColor: COLORS.taylr,
    padding: 5,
    flexDirection: 'row',
    margin: 5,
  },
  courseTagIcon: {
    width: 22,
    height: 17,
  },
  courseTagText: {
    fontSize: 14,
    color: 'white',
    marginLeft: 5,
  },
});


export default renderCourses
