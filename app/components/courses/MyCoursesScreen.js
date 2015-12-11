import React, {
  StyleSheet,
  Text,
  Image,
  View,
  PropTypes,
  ScrollView,
  TouchableOpacity,
  AlertIOS
} from 'react-native';

import { connect } from 'react-redux/native';
import { SHEET, COLORS } from '../../CommonStyles'
import { formatCourse } from '../courses/coursesCommon'
const logger = new (require('../../../modules/Logger'))('MyCoursesScreen')

function mapStateToProps(state) {
  return {
    courses: state.myCourses,
  }
}

class MyCoursesScreen extends React.Component {

  static propTypes = {
    courses: PropTypes.array.isRequired,
    onRemoveCourse: PropTypes.func.isRequired,
  };

  render() {
    logger.info(`courses=${JSON.stringify(this.props.courses)}`)
    var addNewCourse = (
      <TouchableOpacity style={styles.courseCardContainer} onPress={this._addNewCourse}>
        <View style={styles.courseCardHeaderContainer}>
          <View style={styles.courseCardLeftSideContainer}>
            <Image
              style={styles.grayCourseIcon}
              source={require('../img/ic-class-icon.png')} />
            <Text style={[SHEET.baseText, styles.courseCardTitle, styles.addNewCourseText]}>Add new course...</Text>
          </View>
          <View style={styles.addNewCourseIconWrapper}>
            <Image
              style={styles.addNewCourseIcon}
              source={require('../img/ic-add.png')} />
          </View>
        </View>
      </TouchableOpacity>
    )

    return (
      <View style={SHEET.container}>
        <ScrollView showsVerticalScrollIndicator={false}>
            <Text style={[SHEET.baseText, styles.headerReminderText]}>We compiled a list of courses that you take, please make sure we didn't make any mistakes.</Text>
            <View style={[SHEET.innerContainer, styles.courseCardsContainer]}>
              { this.props.courses.map(course => {
                return this._renderCourseCard(course);
              })}
              {addNewCourse}
            </View>
        </ScrollView>
      </View>
    )
  }

  _renderCourseCard(course) {
    return (
      <View style={styles.courseCardContainer} key={course._id}>
        <View style={styles.courseCardHeaderContainer}>
          <View style={styles.courseCardLeftSideContainer}>
            <Image
              style={styles.courseIcon}
              source={require('../img/ic-class-icon.png')} />
            <Text style={[SHEET.baseText, styles.courseCardTitle]}>{formatCourse(course.dept, course.course)}</Text>
          </View>
          <TouchableOpacity
            style={styles.courseCardArrowButton}
            onPress={() => this._removeCourse(course)}>
            <Image
              style={styles.courseCardArrowIcon}
              source={require('../img/ic-cross.png')} />
          </TouchableOpacity>
        </View>
        <Text style={[SHEET.baseText, styles.courseDescriptionText]}>{course.description}</Text>
      </View>
    )
  }

  _removeCourse(course) {
    AlertIOS.alert(
      'Remove Course',
      'Do you really want to remove this course?',
      [
        {text: 'Delete', onPress: () => {
          this.props.onRemoveCourse(course._id)}, style: 'destructive'},
        {text: 'Cancel', style: 'cancel'}
      ]
    )
  }

  _addNewCourse() {

  }
}

var styles = StyleSheet.create({
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
  headerReminderText: {
    marginTop: 10,
    fontSize: 18,
    color: '#4A4A4A',
    textAlign: 'center',
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
    //borderRadius: 3,
    padding: 8,
  },
  courseCardArrowButton: {
    alignSelf: 'center',
    padding: 15,
    borderRadius: 3,
  },
  courseCardArrowIcon: {
    width: 15,
    height: 15,
    tintColor: '#737373',
  },
  courseDescriptionText: {
    fontSize: 11,
    paddingHorizontal: 10,
    paddingBottom: 10,
  }
});

export default connect(mapStateToProps)(MyCoursesScreen)
