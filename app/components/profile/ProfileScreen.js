import React, {
  StyleSheet,
  View,
  Text,
} from 'react-native';

import { connect } from 'react-redux/native';

class ProfileScreen extends React.Component {

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
