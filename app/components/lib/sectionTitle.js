import React, {
  View,
  Text,
  StyleSheet,
} from 'react-native';

import { SHEET } from '../../CommonStyles';

export default function sectionTitle(text, styleOverride) {
  return (
    <View style={[styles.titleView, styleOverride]}>
      <Text style={[styles.title, SHEET.baseText]}>
        { text }
      </Text>
    </View>
  )
}

var styles = StyleSheet.create({
  titleView: {
    paddingBottom: 5,
    paddingTop: 20,
  },
  title: {
    fontSize: 14,
    color: '#999999'
  },
});
