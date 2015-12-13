import React, {
  Image,
  Text,
  View,
  ScrollView,
  TouchableOpacity,
  StyleSheet,
} from 'react-native';

import { Card } from '../lib/Card';
import { SHEET } from '../../CommonStyles';

const grayToIconMapping = {
  facebook: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-facebook-gray.png',
  instagram: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-instagram-gray.png',
  github: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-github-gray.png',
  twitter: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-twitter-gray.png',
  soundcloud: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-soundcloud-gray.png'
};

const iconMapping = {
  facebook: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-facebook.png',
  instagram: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-instagram.png',
  github: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-github.png',
  twitter: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-twitter.png',
  soundcloud: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-soundcloud.png'
};

const logger = new (require('../../../modules/Logger'))('ProfileScreen');

function renderProfile(profile, activeProfile, onPress) {
  let source;
  if (profile.integrationName == 'taylr') {
    if (activeProfile == 'taylr') {
      source = require('../img/ic-taylr-colored.png');
    } else {
      source = require('../img/ic-taylr-gray.png');
    }
  } else {
    if (profile.integrationName == activeProfile) {
      source = { uri: iconMapping[activeProfile] }
    } else {
      source = { uri: grayToIconMapping[profile.integrationName] }
    }
  }

  const additionalStyles = { marginHorizontal: 5 };

  return (
    <TouchableOpacity
      key={profile.integrationName}
      onPress={() => { return onPress(profile) }}>
      <Image
          style={[SHEET.iconCircle, additionalStyles]}
          source={source} />
    </TouchableOpacity>
  )
}

export default function renderServiceIconsBanner(profiles, activeProfile, onPress) {

  return (
    <Card
      style={styles.card}
      cardOverride={{ padding: 10 }}
      hideSeparator={true}>
      <ScrollView
        showsHorizontalScrollIndicator={false}
        horizontal={true}>

        { profiles.map(profile => { return renderProfile(profile, activeProfile, onPress) })}

      </ScrollView>
    </Card>
  )
}

var styles = StyleSheet.create({
  activityHeader: {
    paddingTop: 12,
    paddingBottom: 8,
    paddingHorizontal: 10
  },
  card: {
    flex: 1,
    alignItems: 'center',
    flexDirection: 'column',
  },
  activityImage: {
    flex: 1,
    resizeMode: 'cover',
  },
});
