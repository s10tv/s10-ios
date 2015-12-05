import React, {
  Image,
  Text,
  StyleSheet,
} from 'react-native';

import { SHEET } from '../../CommonStyles';
import { Card } from '../lib/Card';

export default function networkCard() {
  return (
    <Card cardOverride={styles.networkCard}>
      <Image source={require('../img/ic-ubc.png')} style={SHEET.icon} />
      <Text style={[styles.networkText, SHEET.baseText]}>University of British Columbia</Text>
    </Card>
  )
}

var styles = StyleSheet.create({
  networkCard: {
    flex: 1,
    alignItems: 'center',
    flexDirection: 'row',
  },
  networkText: {
    flex: 1,
    left: 8,
  }
});
