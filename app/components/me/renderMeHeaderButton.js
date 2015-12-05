import React, {
  Text,
  View,
  TouchableOpacity,
  StyleSheet,
} from 'react-native'

import Dimensions from 'Dimensions'
import { SHEET } from '../../CommonStyles';

const logger = new (require('../../../modules/Logger'))('renderMeHeaderButton');
const { width, height } = Dimensions.get('window');

export default function renderMeHeaderButton(text, onPress, additionalStyles = {}) {
  return(
    <View style={[styles.container, additionalStyles]}>
      <TouchableOpacity
        onPress={onPress}>
          <View style={[styles.button, styles.buttonShadow]} />
          <View style={styles.button}>
            <Text style={[styles.buttonText, SHEET.baseText]}>
              { text }
            </Text>
          </View>
      </TouchableOpacity>
    </View>
  )
}

var styles = StyleSheet.create({
  container: {
    borderWidth: 1,
    borderColor: 'white',
    alignItems: 'center',
    borderRadius: 2,
  },
  buttonShadow: {
    position:'absolute',
    backgroundColor: 'black',
    opacity: 0.6,
  },
  button: {
    width: 5 * width / 16,
    height: height / 24,
    alignItems: 'center',
    justifyContent: 'center',
  },
  buttonText: {
    fontSize:16,
    color:'white',
  }
});
