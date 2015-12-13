import React, {
  Image,
  Text,
  View,
  StyleSheet,
} from 'react-native';

import TimeDifferenceCalculator from '../../util/TimeDifferenceCalculator';
import { Card } from '../lib/Card';
import { SHEET } from '../../CommonStyles';

const logger = new (require('../../../modules/Logger'))('ProfileScreen');

export default function renderActivity(activity, connectedProfiles) {
  var image = null;
  if (activity.image) {
    image = <Image style={[{ height: 300 }, styles.activityImage]}
      source={{ uri: activity.image.url }} />
  }

  var caption = null;
  if (activity.caption) {
    caption = (
      <View style={[styles.activityElement, styles.caption]}>
        <Text style={[SHEET.subTitle, SHEET.baseText]}>{activity.caption}</Text>
      </View>
    )
  }

  var text = null;
  if (activity.text) {
    text = (
      <View style={styles.activityElement}>
        <Text style={SHEET.baseText}>{activity.text}</Text>
      </View>
    )
  }

  var source = null;
  var header = null;
  let profile = connectedProfiles[activity.profileId]

  if (profile) {
    source = (
      <View style={[{ paddingBottom: 10 }, styles.activityElement]}>
        <Text style={[SHEET.baseText]}>
          via <Text style={[{fontWeight: 'bold', color: profile.themeColor }, SHEET.baseText]}>
            {profile.integrationName}
          </Text>
        </Text>
      </View>
    )

    header = (
      <View style={[ styles.activityHeader, SHEET.row]}>
        <Image source={{ uri: profile.avatar.url }}
          style={[{ marginRight: 5}, SHEET.iconCircle]} />
        <View style={{ flex: 1 }}>
          <Text style={[SHEET.baseText]}>{profile.displayId}</Text>
        </View>
        <View style={{ width: 32 }}>
          <Text style={ [SHEET.subTitle, SHEET.baseText] }>
            { TimeDifferenceCalculator.calculate(new Date(), activity.timestamp) }
          </Text>
        </View>
      </View>
    )
  }

  return (
    <Card
      key={activity._id}
      style={[styles.card, SHEET.innerContainer]}
      hideSeparator={true}
      cardOverride={{ padding: 0 }}>
        {header}
        {image}
        {caption}
        {text}
        {source}
    </Card>
  )
}

var styles = StyleSheet.create({
  activityElement: {
    flex: 1,
    paddingTop: 10,
    paddingHorizontal: 10,
  },
  activityHeader: {
    paddingTop: 12,
    paddingBottom: 8,
    paddingHorizontal: 10
  },
  card: {
    flex: 1,
    marginTop: 8,
    borderRadius: 3,
    paddingVertical: 3,
  },
  activityImage: {
    flex: 1,
    resizeMode: 'cover',
  },
});
