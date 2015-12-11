
// let resonSection;
// if (candidate.reason) {
//   reasonSection = (
//     <View style={[{ flex: 1}, styles.infoSection, SHEET.innerContainer]}>
//       <Text style={[SHEET.baseText]}>
//         { candidate.reason }
//       </Text>
//     </View>
//   )
// }
//
// // TODO override for now
// reasonSection = (
//
// )

import React, {
  View,
  Text,
  StyleSheet,
} from 'react-native';

import { COLORS } from '../../CommonStyles';
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

  return (
    <View style={styles.container}>
      { toRender }
    </View>
  )
}

var styles = StyleSheet.create({
  container: {
    padding: 6,
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
