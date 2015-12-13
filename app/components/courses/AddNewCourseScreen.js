import React, {
  View,
  Image,
  Text,
  ScrollView,
  TouchableOpacity,
  StyleSheet,
} from 'react-native';

import { connect } from 'react-redux/native';
import { SHEET } from '../../CommonStyles';
import { Card } from '../lib/Card';
import AllCoursesListView from '../lib/AllCoursesListView';
import { inactiveCourseCard, giveUsersInCoursesWithoutMyAvatar } from './coursesCommon'
import Routes from '../../nav/Routes';

const logger = new (require('../../../modules/Logger'))('AddNewCourseScreen')

function mapStateToProps(state) {
  return {
    ddp: state.ddp,
    me: state.me
  }
}

class AddNewCourseScreen extends React.Component {

  renderCourse(course) {
    course.usersInCourse = giveUsersInCoursesWithoutMyAvatar(course, this.props.me);
    return inactiveCourseCard(course, () => {
      this.props.ddp.call({ methodName: 'courses/add', params:[course] })
      .then(() => {
        this.props.navigator.pop();
      })
      .catch(err => {
        logger.error(err);
        this.props.dispatch({
          type: 'DISPLAY_ERROR',
          title: 'Adding Course',
          message: 'There was a problem adding your course :C',
        })
      })
    }, () => {
      const route = Routes.instance.getCourseDetailRoute(course, false);
      this.props.navigator.push(route);
    })
  }

  render() {
    return (
      <View style={SHEET.container}>
        <AllCoursesListView
          style={styles.allCoursesListView}
          navigator={this.props.navigator}
          renderCourse={(course) => {
            return this.renderCourse(course);
          }}
          ddp={this.props.ddp} />
      </View>
    )
  }
}

var styles = StyleSheet.create({
  allCoursesListView: {
    flex: 1,
  },
});

export default connect(mapStateToProps)(AddNewCourseScreen)
