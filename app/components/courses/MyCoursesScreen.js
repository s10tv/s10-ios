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
import { SHEET } from '../../CommonStyles'
import { formatCourse, giveUsersInCoursesWithoutMyAvatar, activeCourseCard, courseActionCard } from '../courses/coursesCommon'
import Routes from '../../nav/Routes'
const logger = new (require('../../../modules/Logger'))('MyCoursesScreen')

function mapStateToProps(state) {
  return {
    courses: state.myCourses,
    ddp: state.ddp,
    me: state.me
  }
}

class MyCoursesScreen extends React.Component {

  static propTypes = {
    courses: PropTypes.array.isRequired,
    onRemoveCourse: PropTypes.func.isRequired,
  };

  render() {
    let importCourseButton = null;
    if (this.props.isOnboarding) {
      importCourseButton = courseActionCard('Import Courses', () => {
        AlertIOS.alert(
          'Import courses',
          'We will be importing your course from CWL.',
          [
            { text: 'Cancel', style: 'cancel'},
            { text: 'Okay', onPress: this.props.onFetchCourses() }
          ]
        )
      })
    }

    return (
      <View style={SHEET.container}>
        <ScrollView showsVerticalScrollIndicator={false}>
            <Text style={[SHEET.baseText, styles.headerReminderText]}>We compiled a list of courses that you take, please make sure we did not make any mistakes.</Text>
            <View style={SHEET.innerContainer}>
              { this.props.courses.loadedCourses.map(course => {
                course.usersInCourse = giveUsersInCoursesWithoutMyAvatar(course, this.props.me);
                return activeCourseCard(course, true, () => this._removeCourse(course))
              })}

              { importCourseButton }
              { courseActionCard('Add new course...', () => {
                const route = Routes.instance.getAllCoursesListRoute();
                this.props.navigator.push(route);
              })}
            </View>
        </ScrollView>
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
}


var styles = StyleSheet.create({
  headerReminderText: {
    marginTop: 10,
    fontSize: 18,
    color: '#4A4A4A',
    textAlign: 'center',
  },
});

exports.MyCoursesScreen = connect(mapStateToProps)(MyCoursesScreen)
