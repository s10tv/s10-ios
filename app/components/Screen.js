import React, {
  TouchableOpacity,
  Text,
} from 'react-native';

import { SHEET } from '../CommonStyles'

class Screen extends React.Component {

  static generateButton(text, action, type = { isLeft: true }) {
    return (
      <TouchableOpacity
        style={type.isLeft ? SHEET.navBarLeftButton : SHEET.navBarRightButton}
        onPress={action}>
          <Text style={[SHEET.navBarText, SHEET.navBarButtonText, SHEET.baseText]}>{text}</Text>
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
