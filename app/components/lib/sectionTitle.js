import React, {
  View,
  Text,
  StyleSheet,
} from 'react-native';

import { SHEET } from '../../CommonStyles';

export default function sectionTitle(text) {
  return (
    <View style={[styles.titleView]}>
      <Text style={[styles.title, SHEET.baseText]}>
        { text }
      </Text>
    </View>
  )
}

var styles = StyleSheet.create({
  titleView: {
    paddingBottom: 4,
    paddingTop: 20,
  },
  title: {
    fontSize: 14,
    color: '#999999'
  },
});
