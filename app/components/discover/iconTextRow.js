import React, {
  View,
  Text,
  Image,
  StyleSheet,
} from 'react-native';

import { SHEET } from '../../CommonStyles';

export default function iconTextRow(iconSource, text) {
  return (
    <View style={styles.row}>
      <Image source={iconSource} />
      <Text style={[styles.text, SHEET.baseText]}>{text}</Text>
    </View>
  )
}

var styles = StyleSheet.create({
  row: {
    flexDirection: 'row',
    padding: 5,
  },
  text: {
    marginLeft: 10,
  }
});
