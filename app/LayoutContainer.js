import React, {
  StyleSheet,
  Component,
  View,
  Text,
  TouchableOpacity
} from 'react-native';

import { connect } from 'react-redux/native';

class LayoutContainer extends React.Component {

  render() {
    return (
      <View style={{ paddingTop: 50 }}>
        <TouchableOpacity onPress={() => {
          this.props.dispatch({
            type: 'INCREMENT_COUNTER'
          })
        }}>
          <View><Text>Increase</Text></View>

        </TouchableOpacity>
        <Text>{ this.props.counter }</Text>
      </View>
    )
  }
}

function mapStateToProps(state) {
  return { counter: state.counter }
}

export default connect(mapStateToProps)(LayoutContainer)
