import React, {
  StyleSheet,
  View,
  Text,
} from 'react-native';

import { connect } from 'react-redux/native';
import { SCREEN_EDIT_PROFILE } from '../../constants';
import Screen from '../Screen';

const logger = new (require('../../../modules/Logger'))('EditProfileScreen');

class EditProfileScreen extends Screen {

  static id = SCREEN_EDIT_PROFILE;
  static leftButton = (route, router) => Screen.generateButton('Back', router.pop.bind(router));
  static rightButton = () => null
  static title = () => Screen.generateTitleBar('Edit');

  render() {
    return (
      <View style={{ paddingTop: 100 }}>
        <Text>Edit Profile Screen!</Text>
      </View>
    )
  }
}

function mapStateToProps(state) {
  return {}
}

export default connect(mapStateToProps)(EditProfileScreen)
