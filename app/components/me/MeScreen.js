import React, {
  Image,
  Text,
  View,
  ScrollView,
  TouchableOpacity,
  StyleSheet,
} from 'react-native'

import { connect } from 'react-redux/native';

import Dimensions from 'Dimensions'
import Screen from '../Screen';
import { SCREEN_ME } from '../../constants';

// constants
const logger = new (require('../../../modules/Logger'))('MeScreen');
const { width, height } = Dimensions.get('window');
const BANNER_HEIGHT = height / 4;

// styles
import networkCard from './networkCard';
import renderMeHeader from './renderMeHeader';
import MoreCard from './MoreCard';
import HeaderBanner from '../lib/HeaderBanner';
import sectionTitle from '../lib/sectionTitle';
import HashtagCategory from '../lib/HashtagCategory';
import { SHEET, COLORS } from '../../CommonStyles';

function mapStateToProps(state) {
  return {
    me: state.me,
    apphub: state.apphub,
  }
}

class MeScreen extends React.Component {

  static id = SCREEN_ME;
  static leftButton = () => Screen.generateButton(null, null);
  static rightButton = () => Screen.generateButton(null, null);
  static title = () => Screen.generateTitleBar('Me');

  render() {
    return (
      <View style={SHEET.container}>
        <ScrollView
          showsVerticalScrollIndicator={false}
          style={[{ top: 64 }]}>

          <HeaderBanner url={this.props.me.coverUrl} height={height/4}>
            { renderMeHeader(this.props.me, this.props.onViewProfile, this.props.onEditProfile) }
          </HeaderBanner>

          <View style={SHEET.innerContainer}>
            { sectionTitle('MY SCHOOL') }
            { networkCard() }

            { sectionTitle('MY HASHTAGS') }
            <HashtagCategory {...this.props} />

            { sectionTitle('MORE') }
            <MoreCard onPressLogout={this.props.onPressLogout} />
          </View>

          <View style={styles.versionTextContainer}>
          <Text style={[styles.versionText, SHEET.innerContainer, SHEET.baseText]}>
            { this.props.apphub.buildName }
          </Text>
          </View>
          <View style={SHEET.bottomTile} />
        </ScrollView>
      </View>
    )
  }
}


var styles = StyleSheet.create({
  versionTextContainer: {
    flex: 1,
    height: 64,
    alignItems: 'center',
    justifyContent: 'center',
  },
  versionText: {
    textAlign: 'center',
    fontSize: 16,
    color: COLORS.emptyHashtag,
  },
});

export default connect(mapStateToProps)(MeScreen)
