import React, {
  Dimensions,
  Image,
  LinkingIOS,
  TouchableOpacity,
  ScrollView,
  Text,
  View,
  StyleSheet,
} from 'react-native';

import { activeCourseCard } from '../courses/coursesCommon';
import sectionTitle from '../lib/sectionTitle';

import HeaderBanner from '../lib/HeaderBanner';
import TimeDifferenceCalculator from '../../util/TimeDifferenceCalculator';
import { SHEET, COLORS } from '../../CommonStyles'
import { Card } from '../lib/Card';
import iconTextRow from '../lib/iconTextRow';
import Routes from '../../nav/Routes';
import Analytics from '../../../modules/Analytics';

const { height, width } = Dimensions.get('window');

export default function renderProfileIntroCard({
    navigator, user, activeProfile, connectedProfiles, me = {}}) {

  profile = connectedProfiles[activeProfile]
  attributes = null
  if (profile && profile.attributes) {
    attributes = profile.attributes.map((attribute) => {
      return (
        <View key={attribute.label} style={styles.attributeBox}>
          <Text style={[SHEET.baseText, styles.attributeText]}>{attribute.value}</Text>
          <Text style={[SHEET.baseText, styles.attributeText]}>{attribute.label}</Text>
        </View>
      )
    });
  }

  let separator = (attributes && attributes.length > 0) ?
    <View style={SHEET.separator} /> :
    null;

  return (
    <Card
        style={[SHEET.innerContainer, styles.card]}
        hideSeparator={true}>
      <View style={styles.horizontal}>
        <Image style={styles.infoAvatar} source={{ uri: profile.avatar.url }} />
        <View style={{flex: 1, left: 10, top: 5}}>
          <Text style={[SHEET.baseText, SHEET.smallHeading]}>{`${user.firstName} ${ user.lastName}`}</Text>
          <Text style={[SHEET.baseText, SHEET.subTitle]}>{ profile.displayName }</Text>
        </View>
        <TouchableOpacity style={[styles.openButton]} onPress={() =>
          LinkingIOS.canOpenURL(profile.url, (supported) => {
            if (!supported) {
              logger.warning(`Profile URL ${profile.url} unsupported.`)
              return;
            } else {
              LinkingIOS.openURL(profile.url);
            }
          })
        }>
            <Text style={[{fontSize: 18, color: COLORS.white }, SHEET.baseText]}>Open</Text>
        </TouchableOpacity>
      </View>
      { separator }
      <ScrollView horizontal={true}
        showsHorizontalScrollIndicator={false}
        style={{ marginHorizontal: 10 }}>
        { attributes }
      </ScrollView>
    </Card>
  )
}

var styles = StyleSheet.create({
  card: {
    flex: 1,
    marginTop: 8,
    borderRadius: 3,
    paddingVertical: 3,
  },
  horizontal: {
    flex: 1,
    flexDirection: 'row',
    paddingBottom: 10,
  },
  infoAvatar: {
    width: 60,
    height: 60,
    borderRadius: 30,
  },
  openButton: {
    marginTop: 10,
    width: 60,
    height: 36,
    borderRadius: 3,
    paddingBottom: 3,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#327BEE',
  },
  attributeBox: {
    marginHorizontal: 15,
    paddingHorizontal: 10,
    paddingTop: 10,
    justifyContent: 'center',
    alignItems: 'center',
  },
  attributeText: {
    fontSize: 20,
    color: COLORS.attributes,
  },
});
