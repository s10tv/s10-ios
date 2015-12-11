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
import { formatCourse } from '../courses/coursesCommon';
import AllCoursesListView from '../lib/AllCoursesListView';
import { inactiveCourseCard } from './coursesCommon'
const logger = new (require('../../../modules/Logger'))('AddNewCourseScreen')

function mapStateToProps(state) {
  return {
    ddp: state.ddp
  }
}

class AddNewCourseScreen extends React.Component {

  renderCourse(course) {
    return inactiveCourseCard(course, () => {
      try {
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
      } catch (err) {
        logger.error(err);
      }
    });
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
