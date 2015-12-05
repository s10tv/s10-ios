import React, {
  StyleSheet,
  View,
  Text,
} from 'react-native';

import { connect } from 'react-redux/native';
import { SCREEN_TODAY } from '../../constants';
import Screen from '../Screen';

class DiscoverScreen extends Screen {

  static id = SCREEN_TODAY;
  static leftButton = () => Screen.generateButton(null, null);
  static rightButton = () => Screen.generateButton(null, null);
  static title = () => Screen.generateTitleBar('Today');

  render() {
    return (
      <View style={{ paddingTop: 100 }}>
        <Text>Discover Screen!</Text>
      </View>
    )
  }
}

function mapStateToProps(state) {
  return {}
}

export default connect(mapStateToProps)(DiscoverScreen)
