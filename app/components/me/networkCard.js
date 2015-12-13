import React, {
  Image,
  Text,
  StyleSheet,
} from 'react-native';

import { SHEET } from '../../CommonStyles';
import { Card } from '../lib/Card';

export default function networkCard() {
  return (
    <Card style={styles.card} hideSeparator={true} cardOverride={styles.networkCard}>
      <Image source={require('../img/ic-ubc.png')} style={SHEET.icon} />
      <Text style={[styles.networkText, SHEET.baseText]}>University of British Columbia</Text>
    </Card>
  )
}

var styles = StyleSheet.create({
  card: {
    flex: 1,
    borderRadius: 3,
    paddingVertical: 3,
  },
  networkCard: {
    flex: 1,
    alignItems: 'center',
    flexDirection: 'row',
    padding: 10,
  },
  networkText: {
    flex: 1,
    left: 8,
  }
});
