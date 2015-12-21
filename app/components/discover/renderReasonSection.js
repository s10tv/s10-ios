import React, {
  View,
  Text,
  StyleSheet,
  Image
} from 'react-native';

import { SHEET, COLORS } from '../../CommonStyles';
import SimilarityCalculator from '../../util/SimilarityCalculator';
import { formatCourse } from '../courses/coursesCommon'

export function renderTag(tag, styleOverride) {
  return (
    <View key={tag.text} style={[styles.tag, styleOverride]}>
      <Text style={[SHEET.baseText, styles.hashtagText]}>#{tag.text}</Text>
    </View>
  )
}

export function renderMoreTag(numMore, styleOverride) {
  return (
    <View key={'more'} style={[styles.tag, styleOverride]}>
      <Text style={[SHEET.baseText, styles.hashtagText]}>+{numMore} more</Text>
    </View>
  )
}

export function renderCourse(course, styleOverride) {
  return (
    <View key={course.courseCode} style={[styles.tag, styles.courseTag, styleOverride]}>
      <Image
        style={styles.courseIcon}
        source={require('../img/ic-class-icon.png')} />
      <Text style={[SHEET.baseText, styles.hashtagText, styles.courseTagText]}>{formatCourse(course.dept, course.course)}</Text>
    </View>
  )
}

export function renderReasonSection(forUser, toUser, styleOverride) {
  const { same, other } = new SimilarityCalculator().calculate(forUser, toUser);

  let renderables = [];
  renderables = renderables.concat(same.courses.map(course => { return renderCourse(course) }))
  renderables = renderables.concat(same.tags.map(tag => { return renderTag(tag) }))

  if (renderables.length == 0) {
    renderables = renderables.concat(other.courses.map(course => { return renderCourse(course) }))
    renderables = renderables.concat(other.tags.map(tag => { return renderTag(tag) }))
  }

  let toRender = renderables.length > 5 ? renderables.slice(0, 5) : renderables;
  if (renderables.length > 5) {
    toRender.push(renderMoreTag(renderables.length - 5))
  }

  return (
    <View style={[styles.container, styleOverride]}>
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
