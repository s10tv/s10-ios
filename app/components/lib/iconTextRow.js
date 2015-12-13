import React, {
  View,
  Text,
  Image,
  StyleSheet,
} from 'react-native';

import { SHEET } from '../../CommonStyles';

export default function iconTextRow(iconSource, text, rowStyle={}, iconStyle={}, textStyle={}) {
  return (
    <View style={[styles.row, rowStyle]}>
      <Image source={iconSource} style={iconStyle} />
      <Text style={[styles.text, SHEET.baseText, textStyle]}>{text}</Text>
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
