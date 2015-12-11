import React, {
  StyleSheet,
  TouchableOpacity,
  Image,
  Text,
  View,
} from 'react-native';

import { SHEET } from '../../CommonStyles';

export function formatCourse(dept, course) {
  var lowercaseDept = dept.toLowerCase()
  return `${lowercaseDept.charAt(0).toUpperCase() + lowercaseDept.slice(1)} ${course}`
}

export function activeCourseCard(course, isRemovable, onPress) {
  var courseCardRemoveButton = isRemovable ? (
        <TouchableOpacity
          style={courseCardStyles.courseCardRemoveButton}
          onPress={onPress}>
          <Image
            style={courseCardStyles.courseCardRemoveIcon}
            source={require('../img/ic-cross.png')} />
        </TouchableOpacity>
      ) : null

  var usersInCourseSection = (!course.usersInCourse || course.usersInCourse.length == 0) ? null : (
    <View>
      <View style={[SHEET.separator, courseCardStyles.separator]} />
      <View style={courseCardStyles.courseCardAvatarContainer}>
        {course.usersInCourse.map(courseUser => {
          return (
            <View key={courseUser.userId}>
              <Image
              source={{ uri: courseUser.avatarUrl }}
              style={courseCardStyles.courseCardAvatar} />
            </View>
          )
        })}
      </View>
    </View>
  );

  return (
    <View style={courseCardStyles.courseCardContainer} key={course._id}>
      <View style={courseCardStyles.courseCardHeaderContainer}>
        <View style={courseCardStyles.courseCardLeftSideContainer}>
          <Image
            style={courseCardStyles.courseIcon}
            source={require('../img/ic-class-icon.png')} />
          <Text style={[SHEET.baseText, courseCardStyles.courseCardTitle]}>{formatCourse(course.dept, course.course)}</Text>
        </View>
        {courseCardRemoveButton}
      </View>
      <Text style={[SHEET.baseText, courseCardStyles.courseDescriptionText]}>{course.description}</Text>
      { usersInCourseSection }
    </View>
  )
}

export function inactiveCourseCard(course, onPress) {
  return (
    <View style={courseCardStyles.courseCardContainer} key={course._id}>
      <View style={courseCardStyles.courseCardHeaderContainer}>
        <View style={courseCardStyles.courseCardLeftSideContainer}>
          <Image
            style={courseCardStyles.grayCourseIcon}
            source={require('../img/ic-class-icon.png')} />
          <Text style={[SHEET.baseText, courseCardStyles.courseCardTitle, courseCardStyles.addNewCourseText]}>{formatCourse(course.dept, course.course)}</Text>
        </View>
        <TouchableOpacity
          style={courseCardStyles.addNewCourseButton}
          onPress={onPress}>
          <Image
            style={courseCardStyles.addNewCourseIcon}
            source={require('../img/ic-add.png')} />
        </TouchableOpacity>
      </View>
      <Text style={[SHEET.baseText, courseCardStyles.courseDescriptionText, courseCardStyles.addNewCourseText]}>{course.description}</Text>
    </View>
  )
}

export function courseActionCard(text, onPress) {
  return (
    <TouchableOpacity style={courseCardStyles.courseCardContainer} onPress={onPress}>
      <View style={courseCardStyles.courseCardHeaderContainer}>
        <View style={courseCardStyles.courseCardLeftSideContainer}>
          <Image
            style={courseCardStyles.grayCourseIcon}
            source={require('../img/ic-class-icon.png')} />
          <Text style={[SHEET.baseText, courseCardStyles.courseCardTitle, courseCardStyles.addNewCourseText]}>{text}</Text>
        </View>
        <View style={courseCardStyles.addNewCourseIconWrapper}>
          <Image
            style={courseCardStyles.addNewCourseIcon}
            source={require('../img/ic-add.png')} />
        </View>
      </View>
    </TouchableOpacity>
  )
}

var courseCardStyles = StyleSheet.create({
  courseIcon: {
    width: 26,
    height: 20,
    tintColor: '#000000',
  },
  grayCourseIcon: {
    width: 26,
    height: 20,
    tintColor: '#9B9B9B',
  },
  courseCardContainer: {
    flexDirection: 'column',
    flex: 1,
    backgroundColor: '#FFFFFF',
    marginVertical: 5,
    borderRadius: 3,
    padding: 1
  },
  courseCardHeaderContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  courseCardLeftSideContainer: {
    flexDirection: 'row',
    padding: 10,
    alignSelf: 'center',
  },
  courseCardTitle: {
    marginLeft: 7,
    fontSize: 16,
  },
  addNewCourseText: {
    color: '#9B9B9B'
  },
  addNewCourseIcon: {
    width: 28,
    height: 28,
  },
  addNewCourseIconWrapper: {
    alignSelf: 'center',
    padding: 8,
  },
  courseCardRemoveButton: {
    alignSelf: 'center',
    padding: 15,
    borderRadius: 3,
  },
  courseCardRemoveIcon: {
    width: 15,
    height: 15,
    tintColor: '#737373',
  },
  courseDescriptionText: {
    fontSize: 11,
    paddingHorizontal: 10,
    paddingBottom: 10,
  },
  addNewCourseButton: {
    alignSelf: 'center',
    padding: 8,
  },
  separator: {
    marginHorizontal: 10,
  },
  courseCardAvatarContainer: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
    flex: 1,
    marginHorizontal: 10,
    marginVertical: 5
  },
  courseCardAvatar: {
    width: 28,
    height: 28,
    borderRadius: 14,
    marginHorizontal: 3,
    borderWidth: 1,
    borderColor: '#737373',
  },
});
