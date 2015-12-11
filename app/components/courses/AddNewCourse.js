import React, {
  View,
  Image,
  Text,
  ScrollView,
  TouchableOpacity,
} from 'react-native';

import { connect } from 'react-redux/native';
import { SHEET } from '../../CommonStyles'
import { formatCourse } from '../courses/coursesCommon'
import SearchBar from 'react-native-search-bar'
const logger = new (require('../../../modules/Logger'))('MyCoursesScreen')

function mapStateToProps(state) {
  return {

  }
}

class AddNewCourse extends React.Component {
  render() {
    return (
      <View style={SHEET.container}>
        
      </View>
    )
  }
}

export default connect(mapStateToProps)(AddNewCourse)
