import React, {
  StyleSheet,
  View,
  Text,
} from 'react-native';

import { connect } from 'react-redux/native';
import { SCREEN_HISTORY } from '../../constants';

class HistoryScreen extends React.Component {

  static id = SCREEN_HISTORY;

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
