import React, {
  TouchableOpacity,
  Text,
} from 'react-native';

import { SHEET } from '../CommonStyles'

class Screen extends React.Component {

  static generateButton(text, action) {
    return (
      <TouchableOpacity onPress={action}>
        <Text>{text}</Text>
      </TouchableOpacity>
    )
  }

  static generateTitleBar(text) {
    return (
      <Text style={[SHEET.navBarTitleText, SHEET.baseText]}>
        { text }
      </Text>
    );
  }
}

module.exports = Screen;
