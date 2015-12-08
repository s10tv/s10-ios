import React, {
  Image,
  Text,
  View,
  StyleSheet,
} from 'react-native'

import Dimensions from 'Dimensions'
import renderMeHeaderButton from './renderMeHeaderButton'
import { SHEET, COLORS } from '../../CommonStyles';
import renderServiceIcons from '../lib/renderServiceIcons';
import Routes from '../../nav/Routes'

const logger = new (require('../../../modules/Logger'))('renderMeHeader');
const { width, height } = Dimensions.get('window');

export default function renderMeHeader(user, navigator) {

  return (
    <View style={styles.meHeader}>
      <Image style={styles.avatar} source={{ uri: user.avatarUrl }} />
      <View style={styles.headerContent}>
        <Text style={[styles.headerText, SHEET.baseText]}>
          { user.displayName }
        </Text>
        <View style={styles.headerContentLineItem}>
          { renderServiceIcons(user.connectedProfiles) }
        </View>
        <View style={styles.headerContentLineItem}>
          { renderMeHeaderButton('View', () => {
              const route = Routes.instance.getProfileRoute({ userId: user.userId });
              navigator.parentNavigator.push(route);
          })}
          { renderMeHeaderButton('Edit',
            () => {
              const route = Routes.instance.getEditProfileRoute();
              navigator.push(route);
            },
            { left: width / 32 })}
        </View>
      </View>
    </View>
  )
}

var styles = StyleSheet.create({
  avatar: {
    borderWidth: 2.5,
    borderColor: 'white',
    borderRadius: width / 8,
    height: width / 4,
    width: width / 4,
  },
  meHeader: {
    position: 'absolute',
    backgroundColor: 'rgba(0,0,0,0)',
    top: 0,
    left: 0,
    alignItems: 'center',
    flexDirection: 'row',
    height: height / 4,
    marginHorizontal: width / 32,
  },
  headerContent: {
    flexDirection: 'column',
    left: width / 32,
  },
  headerContentLineItem: {
    flex: 1,
    flexDirection: 'row',
    marginTop: 10,
  },
  headerText: {
    color: 'white',
    fontSize: 24
  },
});
