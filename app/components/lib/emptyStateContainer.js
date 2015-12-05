import React, {
  Text,
  View,
  Image,
  StyleSheet,
} from 'react-native';

let Dimensions = require('Dimensions');
let { width, height } = Dimensions.get('window');

// styles
import { SHEET, COLORS } from '../../CommonStyles';

export default function emptyStateContainer(source, message) {
  return (
    <View style={[SHEET.container]}>
      <View style={styles.emptyStateContainer}>
        <Image source={source} style={styles.emptyStateImage} />
        <Text style={[styles.emptyStateText, SHEET.baseText]}>
          Your conversations will be here :)
        </Text>
      </View>
    </View>
  )
}

var styles = StyleSheet.create({
  emptyStateContainer: {
    flex: 1,
    height: height,
    justifyContent: 'center',
    alignItems: 'center',
    marginHorizontal: width / 8,
  },
  emptyStateImage: {
    width: width / 4,
    height: width / 4,
    resizeMode: 'contain',
  },
  emptyStateText: {
    paddingTop: 10,
    fontSize: 20,
    color: COLORS.attributes,
    textAlign: 'center',
  }
});
