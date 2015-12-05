import React, {
  StyleSheet,
  View,
  Text,
} from 'react-native';

import { connect } from 'react-redux/native';
import { SCREEN_HISTORY } from '../../constants';
import Screen from '../Screen';

class HistoryScreen extends Screen {

  static id = SCREEN_HISTORY;
  static leftButton = (route, router) => Screen.generateButton('Back', router.pop.bind(router));
  static rightButton = () => null
  static title = () => null

  render() {
    return (
      <View style={{ paddingTop: 100 }}>
        <Text>History Screen!</Text>
      </View>
    )
  }
}

function mapStateToProps(state) {
  return {}
}

export default connect(mapStateToProps)(HistoryScreen)
