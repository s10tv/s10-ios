import React, {
  Image,
  Text,
  View,
  NativeModules,
  PropTypes,
  StyleSheet,
} from 'react-native';

import Analytics from '../../../modules/Analytics';
import { SHEET } from '../../CommonStyles';
import { TappableCard } from '../lib/Card';
import Routes from '../../nav/Routes';

const Intercom = NativeModules.TSIntercomProvider;
const logger = new (require('../../../modules/Logger'))('MoreCard');

class MoreCard extends React.Component {

  static propTypes = {
    onPressLogout: PropTypes.func.isRequired,
    navigator: PropTypes.object.isRequired,
  };

  contactUs() {
    Intercom.presentConversationList();
  }

  render() {
    return (
      <View>
        <TappableCard style={styles.card} onPress={this.contactUs}>
          <Text style={[SHEET.baseText]}>Contact Us</Text>
        </TappableCard>
        <TappableCard style={styles.card}
          onPress={ () => {
            logger.debug('pressed logout');
            this.props.onPressLogout()

            const route = Routes.instance.getLoginRoute();
            this.props.navigator.parentNavigator.push(route)
          }}>
          <Text style={[SHEET.baseText]}>Logout</Text>
        </TappableCard>
      </View>
    )
  }
}

var styles = StyleSheet.create({
  card: {
    flex: 1,
  }
});

module.exports = MoreCard;
