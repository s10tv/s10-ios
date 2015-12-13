import React, {
  AlertIOS,
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

  onImportCourses() {
    AlertIOS.alert(
      `Import Courses`,
      "We will need you to authenticate through UBC so we can get your course info.",
      [
        {text: 'Cancel', onPress: () => null },
        {text: 'Okay', onPress: () => {
          const route = Routes.instance.getReloginForCourseFetchRoute()
          this.props.navigator.push(route);
        }}
    ])
  }

  render() {
    let optionalUpgradeCard = null
    let hideSeparatorForImportCourses = true;
    // if (this.props.shouldShowUpgradeCard) {
      optionalUpgradeCard = (
        <TappableCard hideSeparator={true} style={styles.card} onPress={this.props.upgrade}>
          <Text style={[SHEET.baseText]}>Upgrade Available</Text>
        </TappableCard>
      )
      hideSeparatorForImportCourses = false;
    //}

    return (
      <View style={styles.container}>
        { optionalUpgradeCard }

        <TappableCard
          hideSeparator={hideSeparatorForImportCourses}
          style={styles.card}
          onPress={ this.onImportCourses.bind(this)}>
            <Text style={[SHEET.baseText]}>Import Courses</Text>
        </TappableCard>

        <TappableCard style={styles.card} onPress={this.contactUs}>
          <Text style={[SHEET.baseText]}>Contact Us</Text>
        </TappableCard>

        <TappableCard style={styles.card}
          onPress={ () => {
            logger.debug('pressed logout');
            this.props.onPressLogout()

            // TODO(qimingfang): onlogout -> immediately reset nav stack.
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
  container: {
    backgroundColor: 'white',
    borderRadius: 3,
    paddingVertical: 3,
  },
  card: {
    flex: 1,
  }
});

module.exports = MoreCard;
