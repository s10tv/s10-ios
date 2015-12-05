import React, {
  StyleSheet,
  View,
  Text,
} from 'react-native';

import { connect } from 'react-redux/native';
import { SCREEN_PROFILE } from '../../constants';
import Screen from '../Screen';

const logger = new (require('../../../modules/Logger'))('ProfileScreen');

class ProfileScreen extends Screen {

  static id = SCREEN_PROFILE;
  static leftButton = (route, router) => Screen.generateButton('Back', router.pop.bind(router));
  static rightButton = () => null;
  static title = () => {
    return Screen.generateTitleBar('Profile');
  }

  render() {
    return (
      <View style={{ flex: 1, backgroundColor: 'purple' }}>
        <Text>Profile Screen!</Text>
      </View>
    )
  }
}

function mapStateToProps(state) {
  return {}
}

export default connect(mapStateToProps)(ProfileScreen)
