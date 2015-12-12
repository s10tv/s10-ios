import React, {
  View,
  Text,
  StyleSheet,
  Image
} from 'react-native';

import { SHEET, COLORS } from '../../CommonStyles';
import SimilarityCalculator from '../../util/SimilarityCalculator';
import { formatCourse } from '../courses/coursesCommon'

function renderTag(tag) {
  return (
    <View style={styles.tag}>
      <Text style={[SHEET.baseText, styles.hashtagText]}>#{tag.text}</Text>
    </View>
  )
}

function renderMoreTag(numMore) {
  return (
    <View style={styles.tag}>
      <Text style={[SHEET.baseText, styles.hashtagText]}>+{numMore} more</Text>
    </View>
  )
}

function renderCourse(course) {
  return (
    <View style={[styles.tag, styles.courseTag]}>
      <Image
        style={styles.courseIcon}
        source={require('../img/ic-class-icon.png')} />
      <Text style={[SHEET.baseText, styles.hashtagText, styles.courseTagText]}>{formatCourse(course.dept, course.course)}</Text>
    </View>
  )
}

export default function renderReasonSection(candidate, forUser, toUser) {
  const { same, other } = new SimilarityCalculator().calculate(forUser, toUser);

  let renderables = [];
  renderables = renderables.concat(same.courses.map(course => { return renderCourse(course) }))
  renderables = renderables.concat(same.tags.map(tag => { return renderTag(tag) }))

  if (renderables.length == 0) {
    renderables = renderables.concat(other.courses.map(course => { return renderCourse(course) }))
    renderables = renderables.concat(other.tags.map(tag => { return renderTag(tag) }))
  }

  let toRender = renderables.length > 6 ? renderables.slice(0, 6) : renderables;
  if (renderables.length > 6) {
    toRender.push(renderMoreTag(renderables.length - 6))
  }

  return (
    <View style={styles.container}>
      { toRender }
    </View>
  )
}

var styles = StyleSheet.create({
  container: {
    padding: 10,
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  tag: {
    padding: 5,
    margin: 5,
    borderWidth: 1,
    borderColor: COLORS.taylr,
  },
  hashtagText: {
    color: COLORS.taylr,
  },
  courseTagText: {
    marginLeft: 5,
  },
  courseTag: {
    flexDirection: 'row',
  },
  courseIcon: {
    width: 22,
    height: 17,
    tintColor: COLORS.taylr,
  },
});
