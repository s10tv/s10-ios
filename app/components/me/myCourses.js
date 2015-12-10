import React, {
  Text,
  TouchableOpacity,
  View,
} from 'react-native';

import { TappableCard } from '../lib/Card';
import { Loader } from '../lib/Loader';

const logger = new (require('../../../modules/Logger'))('renderCourse');

function renderCourse(course, onRemoveCourse) {
  return (
    <TappableCard key={course._id} onPress={() => {
      return onRemoveCourse(course._id)
    }}>
      <View style={{ flex: 1, flexDirection: 'row'}}>
        <Text style={{flex: 1}}>{course.dept} {course.course}</Text>
        <Text style={{width: 100, textAlign: 'right'}}>{course.days}</Text>
      </View>
    </TappableCard>
  )
}

export default function myCourses(courses, onRemoveCourse) {

  return courses.map(course => {
    return renderCourse(course, onRemoveCourse);
  })
}
