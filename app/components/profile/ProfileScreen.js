import React, {
  StyleSheet,
  View,
  Text,
} from 'react-native';

import { connect } from 'react-redux/native';
import { SCREEN_PROFILE } from '../../constants'

class ProfileScreen extends React.Component {

  static id = SCREEN_PROFILE;

  render() {
    return (
      <View style={{ paddingTop: 100 }}>
        <Text>Profile Screen!</Text>
      </View>
    )
  }
}

function mapStateToProps(state) {
  return {}
}

export default connect(mapStateToProps)(ProfileScreen)
