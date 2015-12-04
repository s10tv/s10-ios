import React, {
  Image,
  Text,
  View,
  StyleSheet,
} from 'react-native'

import { connect } from 'react-redux/native';

import { SCREEN_ME } from '../../constants';

// constants
const logger = new (require('../../../modules/Logger'))('MeScreen');

function mapStateToProps(state) {
  return {
    me: state.me
  }
}

class MeScreen {

  static id = SCREEN_ME;

  showProfile() {
    this.props.dispatch({
      type: 'PROFILE_SCREEN',
      souce: 'me'
    })
  }

  render() {
    return (
      <View style={{ paddingTop: 60 }}>
        <Text>Me Screen</Text>
        <Text>{ this.props.me.firstName } { this.props.me.lastName }</Text>
        <Text onPress={this.showProfile.bind(this)}>My Profile</Text>
        <Text onPress={this.props.onPressLogout}>Log Out</Text>
      </View>
    )
  }
}

export default connect(mapStateToProps)(MeScreen)
