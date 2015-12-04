import React, {
  StyleSheet,
  View,
  Text,
} from 'react-native';

import { connect } from 'react-redux/native';

class DiscoverScreen extends React.Component {

  onLogout() {
    this.props.dispatch({
      type: 'LOGOUT'
    })
  }

  render() {
    return (
      <View style={{ paddingTop: 100 }}>
        <Text>Discover Screen!</Text>
        <Text onPress={this.onLogout.bind(this)}>Log Out</Text>
      </View>
    )
  }
}

function mapStateToProps(state) {
  return {}
}

export default connect(mapStateToProps)(DiscoverScreen)
