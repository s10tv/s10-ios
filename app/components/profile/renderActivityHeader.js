import React, {
  Dimensions,
  Image,
  Text,
  View,
  StyleSheet,
} from 'react-native';

import HeaderBanner from '../lib/HeaderBanner';
import TimeDifferenceCalculator from '../../util/TimeDifferenceCalculator';
import { SHEET, COLORS } from '../../CommonStyles'

const { height, width } = Dimensions.get('window');

export default function renderActivityHeader(user) {
  return (
    <HeaderBanner url={ user.coverUrl } height={ height / 3 }>
      <View style={[ { height: height / 3, top: height / 12 }, styles.activityUser]}>
        <Image source={{ uri: user.avatarUrl }} style={{ width: height / 6, height: height / 6,
            borderRadius: height / 12, borderColor: 'white', borderWidth: 2.5 }} />
        <Text style={[{ marginTop: height / 96}, styles.activityUserTitle, SHEET.baseText]}>
          {user.longDisplayName}
        </Text>
      </View>
    </HeaderBanner>
  )
}

var styles = StyleSheet.create({
  activityUser: {
    flex: 1,
    position: 'absolute',
    alignItems: 'center',
    backgroundColor: 'rgba(0,0,0,0)',
    left: 0,
    width: width,
  },
  activityUserTitle: {
    fontSize: 22,
    color: COLORS.white,
  },
});
