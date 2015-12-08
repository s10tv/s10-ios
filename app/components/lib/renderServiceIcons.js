import React, {
  Image,
  StyleSheet,
} from 'react-native'

import { SHEET, COLORS } from '../../CommonStyles';

export default function renderServiceIcons(
    connectedProfiles,
    defaultProfile = { id: 'ubc', source: require('../img/ic-ubc.png') }) {

  let serviceIcons = [];
  if (defaultProfile) {
    serviceIcons.push(defaultProfile);
  }

  if (connectedProfiles) {
    const connectedProfileIcons = connectedProfiles.map(profile => {
      return { id: profile.id, source: { uri: profile.icon.url }};
    })
    serviceIcons = serviceIcons.concat(connectedProfileIcons);
  }

  return serviceIcons.map(icon => {
    return (
      <Image
        key={icon.id}
        source={icon.source}
        style={[SHEET.smallIcon, styles.serviceIcon]}
      />
    )
  })
}

var styles = StyleSheet.create({
  serviceIcon: {
    marginRight: 5,
  },
});
