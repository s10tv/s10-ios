import React, {
  Image,
  Text,
  View,
  NativeModules,
  StyleSheet,
} from 'react-native';

import Analytics from '../../../modules/Analytics';
import { SHEET } from '../../CommonStyles';
import { TappableCard } from '../lib/Card';

const Intercom = NativeModules.TSIntercomProvider;

class MoreCard extends React.Component {

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
          onPress={ this.props.onPressLogout }>
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
