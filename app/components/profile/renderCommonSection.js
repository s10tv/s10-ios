import React, {
  View,
  Text,
  StyleSheet,
  Image,
} from 'react-native';

import { COLORS, SHEET } from '../../CommonStyles';
import { Card } from '../lib/Card';
import sectionTitle from '../lib/sectionTitle';
import SimilarityCalculator from '../../util/SimilarityCalculator';
import { formatCourse } from '../courses/coursesCommon'
import { renderCourse, renderTag } from '../discover/renderReasonSection';

export function renderCommonSection(forUser, toUser) {
  const { same, other } = new SimilarityCalculator().calculate(forUser, toUser);

  let renderables = [];
  renderables = renderables.concat(same.courses.map(course => { return renderCourse(course) }))
  renderables = renderables.concat(same.tags.map(tag => { return renderTag(tag) }))

  if (renderables.length > 0) {
    return (
      <View>
        { sectionTitle('IN COMMON') }
        <Card
            style={styles.card}
            hideSeparator={true}
            cardOverride={styles.container}>
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
  card: {
    flex: 1,
    borderRadius: 3,
    paddingVertical: 3,
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
