import React, {
  Image,
  Text,
  View,
  StyleSheet,
} from 'react-native'

import { connect } from 'react-redux/native';

import { SCREEN_ME } from '../../constants';
import Screen from '../Screen';

// constants
const logger = new (require('../../../modules/Logger'))('MeScreen');

function mapStateToProps(state) {
  return {
    me: state.me
  }
}

class MeScreen extends React.Component {

  static id = SCREEN_ME;
  static leftButton = () => Screen.generateButton(null, null);
  static rightButton = () => Screen.generateButton(null, null);
  static title = () => Screen.generateTitleBar('Me');

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
        <Text onPress={() => {
          return this.props.onViewProfile(this.props.me.userId);
        }}>My Profile</Text>
        <Text onPress={this.props.onPressLogout}>Log Out</Text>
      </View>
    )
  }
}

export default connect(mapStateToProps)(MeScreen)
