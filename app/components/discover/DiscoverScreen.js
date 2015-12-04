import React, {
  StyleSheet,
  View,
  Text,
} from 'react-native';

import { connect } from 'react-redux/native';

class DiscoverScreen extends React.Component {

  render() {
    return (
      <View style={{ paddingTop: 100 }}>
        <Text>Discover Screen!</Text>
        <Text onPress={this.props.onPressLogout}>Log Out</Text>
      </View>
    )
  }
}

function mapStateToProps(state) {
  return {}
}

export default connect(mapStateToProps)(DiscoverScreen)
