import React, {
  View,
  Text,
  StyleSheet,
} from 'react-native';

import { COLORS } from '../../CommonStyles';
import { Card } from '../lib/Card';
import sectionTitle from '../lib/sectionTitle';
import SimilarityCalculator from '../../util/SimilarityCalculator';

function renderTag(tag) {
  return (
    <View style={styles.tag}>
      <Text style={{ color: COLORS.taylr}}>{ tag.text }</Text>
    </View>
  )
}

function renderCourse(course) {
  return (
    <View style={styles.tag}>
      <Text style={{ color: COLORS.taylr }}>{ course.dept } { course.course }</Text>
    </View>
  )
}

export default function renderCommonSection(forUser, toUser) {
  const { same, other } = new SimilarityCalculator().calculate(forUser, toUser);

  let renderables = [];
  renderables = renderables.concat(same.courses.map(course => { return renderCourse(course) }))
  renderables = renderables.concat(same.tags.map(tag => { return renderTag(tag) }))

  if (renderables.length > 0) {
    return (
      <View>
        { sectionTitle('IN COMMON') }
        <Card cardOverride={styles.container}>
          { renderables }
        </Card>
      </View>
    )
  }

  return null;
}

var styles = StyleSheet.create({
  container: {
    padding: 5,
    flexDirection: 'row',
    flexWrap: 'wrap',
    alignItems: 'center',
  },
  tag: {
    padding: 6,
    margin: 6,
    borderWidth: 1,
    borderColor: COLORS.taylr,
  },
  hashtagText: {
    color: COLORS.white,
  }
});
