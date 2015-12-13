import React, {
  StyleSheet,
  TouchableOpacity,
  Image,
  Text,
  View,
} from 'react-native';

import { SHEET, COLORS } from '../../CommonStyles';
let logger = new (require('../../../modules/Logger'))('coursesCommon');

// MISC

export function giveUsersInCoursesWithoutMyAvatar(course, me) {
  if (course.usersInCourse) {
    return course.usersInCourse.filter(user => {
      return me.userId != user.userId;
    })
  }
}

export function formatCourse(dept, course) {
  var lowercaseDept = dept.toLowerCase()
  return `${lowercaseDept.charAt(0).toUpperCase() + lowercaseDept.slice(1)} ${course}`
}

// CARDS

export function activeCourseCard(course, isRemovable, onPress, onCardPress= null, extraStyle={}) {
  var courseCardRemoveButton = isRemovable ? (
        <TouchableOpacity
          style={courseCardStyles.courseCardRemoveButton}
          onPress={onPress}>
          <Image
            style={courseCardStyles.courseCardRemoveIcon}
            source={require('../img/ic-cross.png')} />
        </TouchableOpacity>
      ) : null

  const cardInfo = (
    <View style={[courseCardStyles.courseCardContainer, extraStyle]} key={course._id}>
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
      {separatorAndUserAvatars(course)}
    </View>
  );

  if (onCardPress) {
    return (
      <TouchableOpacity key={course._id} onPress={onCardPress}>
        { cardInfo }
      </TouchableOpacity>
    )
  }
  return cardInfo;
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
      {separatorAndUserAvatars(course)}
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

// CARD'S SMALLER COMPONENTS

function separatorAndUserAvatars(course) {
  if (course.usersInCourse) {
    return course.usersInCourse.length == 0 ? null :
      (
        <View>
          <View style={[SHEET.separator, courseCardStyles.separator]} />
          <View style={courseCardStyles.courseCardAvatarContainer}>
            {userAvatars(course)}
          </View>
        </View>
      )
  }

  return null;
}

function userAvatars(course) {
  var userAvatar = (courseUser) => {
    return (
      <View key={courseUser.userId}>
        <Image
        source={{ uri: courseUser.avatarUrl }}
        style={courseCardStyles.courseCardAvatar} />
      </View>
    )
  }

  let maxRenderedAvatarCount = 3;
  let usersInCourseCount = course.usersInCourse.length;
  if (course.usersInCourse.length > maxRenderedAvatarCount) {
    return course.usersInCourse.slice(0, maxRenderedAvatarCount).map(courseUser => {
      return userAvatar(courseUser)
    }).concat([moreUsersCircle(usersInCourseCount - maxRenderedAvatarCount)]);
  } else {
    return course.usersInCourse.map(courseUser => {
      return userAvatar(courseUser)
    });
  }
}

function moreUsersCircle(numOfMoreUsers) {
  return (
    <View key={'more'} style={[courseCardStyles.courseCardAvatar, courseCardStyles.courseCardMoreUsersCircle]}>
      <Text numberOfLines={1} style={[SHEET.baseText, courseCardStyles.courseCardMoreUsersText]} allowFontScaling={true}>+{numOfMoreUsers}</Text>
    </View>
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
    padding: 10,
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
    padding: 10,
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
    marginLeft: 6,
    borderWidth: 1,
    borderColor: '#737373',
  },
  courseCardMoreUsersCircle: {
    backgroundColor: COLORS.background,
    overflow: 'hidden',
    justifyContent: 'center',
  },
  courseCardMoreUsersText: {
    fontSize: 11,
    textAlign: 'center',
    marginBottom: 1,
  }
});
