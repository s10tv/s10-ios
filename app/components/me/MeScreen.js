import React, {
  Image,
  Text,
  View,
  ScrollView,
  TouchableOpacity,
  PropTypes,
  StyleSheet,
} from 'react-native'

import { connect } from 'react-redux/native';

import Dimensions from 'Dimensions'
import Screen from '../Screen';
import { SCREEN_ME } from '../../constants';
import BridgeManager from '../../../modules/BridgeManager';

// constants
const logger = new (require('../../../modules/Logger'))('MeScreen');
const { width, height } = Dimensions.get('window');
const BANNER_HEIGHT = height / 4;

// styles
import networkCard from './networkCard';
import renderCourses from './myCoursesCard';
import renderMeHeader from './renderMeHeader';
import MoreCard from './MoreCard';
import HeaderBanner from '../lib/HeaderBanner';
import sectionTitle from '../lib/sectionTitle';
import HashtagCategory from '../lib/HashtagCategory';
import { SHEET, COLORS } from '../../CommonStyles';

function mapStateToProps(state) {
  return {
    ddp: state.ddp,
    me: state.me,
    myCourses: state.myCourses,
    apphub: state.apphub,
    shouldShowUpgradeCard: state.shouldShowUpgradeCard,
  }
}

class MeScreen extends React.Component {

  static id = SCREEN_ME;
  static propTypes = {
    me: PropTypes.object.isRequired,
    apphub: PropTypes.object.isRequired,
    shouldShowUpgradeCard: PropTypes.bool.isRequired,
    upgrade: PropTypes.func.isRequired,
    onFetchCourses: PropTypes.func.isRequired,
  };

  render() {
    const props = this.props;

    return (
      <View style={SHEET.container}>
        <ScrollView
          showsVerticalScrollIndicator={false}>

          <HeaderBanner url={this.props.me.coverUrl} height={height/4}>
            { renderMeHeader(this.props.me, this.props.navigator) }
          </HeaderBanner>

          <View style={SHEET.innerContainer}>
            { sectionTitle('MY SCHOOL') }
            { networkCard() }

            { sectionTitle('MY COURSES') }
            { renderCourses(this.props.myCourses, this.props.navigator) }

            { sectionTitle('MY HASHTAGS') }
            <HashtagCategory {...props} />

            { sectionTitle('MORE') }
            <MoreCard
              navigator={this.props.navigator}
              onFetchCourses={this.props.onFetchCourses}
              shouldShowUpgradeCard={this.props.shouldShowUpgradeCard}
              upgrade={this.props.upgrade}
              onPressLogout={this.props.onPressLogout} />
          </View>

          <View style={styles.versionTextContainer}>
            <Text style={[styles.versionText, SHEET.innerContainer, SHEET.baseText]}>
              { `v${BridgeManager.version()} | ${BridgeManager.build()}` +
               ` | AH: ${this.props.apphub.buildName}` }
            </Text>
          </View>
        </ScrollView>
      </View>
    )
  }
}


var styles = StyleSheet.create({
  versionTextContainer: {
    flex: 1,
    top: 24,
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
