import React, {
  AppRegistry,
  View,
  Text,
  ScrollView,
  StyleSheet,
} from 'react-native';

// external dependencies
import { connect } from 'react-redux/native';

import { SCREEN_OB_LINK_SERVICE } from '../../constants';
import linkServiceCard from '../lib/linkServiceCard';

let SHEET = require('../../CommonStyles').SHEET;
let COLORS = require('../../CommonStyles').COLORS;
let Loader = require('../lib/Loader');
let Screen = require('../Screen');

function mapStateToProps(state) {
  return {
    integrations: state.integrations,
  }
}

class LinkServiceView extends React.Component {
  static id = SCREEN_OB_LINK_SERVICE;
  static leftButton = (route, router) => Screen.generateButton('Back', router.pop.bind(router));
  static rightButton = (route, router) => null
  static title = () => null

  render() {
    let integrations = this.props.integrations;
    if (!integrations) {
      return <Loader />
    }

    return (
      <View style={SHEET.container}>
        <ScrollView
          showsVerticalScrollIndicator={false}
          style={[SHEET.innerContainer, SHEET.navTop]}>

          <View style={styles.instructions}>
            <Text style={[styles.instructionItem, SHEET.baseText]}>
              Showcase your hobbies and passions!
            </Text>
            <Text style={[styles.instructionItem, SHEET.baseText]}>
              We use data from networks to tell a story about you and help introduce
              you to interesting people.
            </Text>
          </View>

          { linkServiceCard(
            this.props.integrations,
            this.props.onLinkFacebook,
            this.props.onLinkViaWebView) }
        </ScrollView>
      </View>
    )
  }
}

var styles = StyleSheet.create({
  instructions: {
    marginVertical: 15,
  },
  instructionItem: {
    marginVertical: 3,
  }
});

export default connect(mapStateToProps)(LinkServiceView)
