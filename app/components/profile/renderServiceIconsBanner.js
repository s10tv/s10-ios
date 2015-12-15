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
import Routes from '../../nav/Routes';

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

  return (
    <TouchableOpacity
      key={profile.integrationName}
      onPress={() => { return onPress(profile) }}>
      <Image
          style={[SHEET.iconCircle, styles.icon]}
          source={source} />
    </TouchableOpacity>
  )
}

export default function renderServiceIconsBanner({
    navigator,
    profiles,
    activeProfile,
    onPress,
    isEditable = false }) {

  let addIntegrationButton = null;
  if (isEditable) {
    addIntegrationButton = (
      <TouchableOpacity onPress={() => {
        const route = Routes.instance.getLinkServiceRoute();
        navigator.push(route);
      }}>
        <Image source={require('../img/ic-add.png')} style={[SHEET.iconCircle, { marginRight: 8 }]} />
      </TouchableOpacity>
    )
  }

  return (
    <Card
      style={styles.card}
      cardOverride={{ flexDirection:'row', padding: 10 }}
      hideSeparator={true}>

      <ScrollView
        style={styles.icons}
        showsHorizontalScrollIndicator={false}
        horizontal={true}>
        { profiles.map(profile => { return renderProfile(profile, activeProfile, onPress) })}
      </ScrollView>

      { addIntegrationButton }
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
  },
  icons: {
    flex: 1,
  },
  icon: {
    marginHorizontal: 5,
  },
  activityImage: {
    flex: 1,
    resizeMode: 'cover',
  },
});
