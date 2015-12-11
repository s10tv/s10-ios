import React, {
  View,
  Image,
  Text,
  ScrollView,
  TouchableOpacity,
} from 'react-native';

import { connect } from 'react-redux/native';
import { SHEET } from '../../CommonStyles';
import { Card } from '../lib/Card';
import { formatCourse } from '../courses/coursesCommon';
import AllCoursesListView from '../lib/AllCoursesListView';

const logger = new (require('../../../modules/Logger'))('MyCoursesScreen')

function mapStateToProps(state) {
  return {
    ddp: state.ddp
  }
}

class AddNewCourse extends React.Component {

  renderCourse(course) {
    return (
      <Card>
        <Text>{course.dept} {course.course}</Text>
        <Text>{course.description}</Text>
      </Card>
    )
  }

  render() {
    return (
      <View style={SHEET.container}>
        <AllCoursesListView
          style={{ flex: 1 }}
          renderCourse={this.renderCourse}
          ddp={this.props.ddp} />
      </View>
    )
  }
}

export default connect(mapStateToProps)(AddNewCourse)
