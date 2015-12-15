import React, {
  Dimensions,
  View,
  ScrollView,
  Text,
  Image,
  TouchableHighlight,
  TouchableOpacity,
  PropTypes,
  StyleSheet,
} from 'react-native';

import { connect } from 'react-redux/native';

import renderReasonSection from './renderReasonSection';
import Screen from '../Screen';
import iconTextRow from '../lib/iconTextRow';
import HeaderBanner from '../lib/HeaderBanner';
import { Card } from '../lib/Card';
import Loader from '../lib/Loader';
import CountdownTimer from '../lib/CountdownTimer';
import { SCREEN_TODAY } from '../../constants';
import { SHEET, COLORS } from '../../CommonStyles';
import Router from '../../nav/Routes';
import Analytics from '../../../modules/Analytics';

const logger = new (require('../../../modules/Logger'))('DiscoverScreen');
const { width, height } = Dimensions.get('window');

function mapStateToProps(state) {
  return {
    me: state.me,
    candidate: state.candidate,
  }
}

class DiscoverScreen extends Screen {

  static propTypes = {
    candidate: PropTypes.object.isRequired,
    navigator: PropTypes.object.isRequired,
  };

  static id = SCREEN_TODAY;
  static leftButton = () => Screen.generateButton(null, null);
  static rightButton = (route, router) => {
    return Screen.generateButton('History', router.toHistory.bind(router), { isLeft: false });
  }
  static title = () => Screen.generateTitleBar('Today');

  render() {
    const candidate = this.props.candidate;

    if (!candidate.loaded) {
      return <Loader />;
    }

    const { coverUrl, connectedProfiles, avatarUrl, major, hometown,
      displayName } = candidate.user;

    let serviceIcons = [<Image
      key="ubc"
      source={require('../img/ic-ubc.png')}
      style={[SHEET.smallIcon, styles.serviceIcon]} />];
    serviceIcons = serviceIcons.concat(connectedProfiles.map((profile) => {
      return <Image key={profile.id} style={[SHEET.smallIcon, styles.serviceIcon]}
          source={{ uri: profile.icon.url }} />
    }));

    return (
      <View style={SHEET.container}>
        <ScrollView style={{flex: 1, paddingTop: 10}} showsVerticalScrollIndicator={false}>
          <TouchableHighlight
              onPress={() => {
                Analytics.track('Today: TapProfile');

                const route = Router.instance.getProfileRoute({
                  user: candidate.user,
                  isFromDiscoveryScreen: true,
                  isEditable: false,
                });

                this.props.navigator.parentNavigator.push(route)
              }}
              style={{ flex: 1}}
              underlayColor={'transparent'}>

            <View style={[{flex: 1}, SHEET.innerContainer]}>
              <HeaderBanner url={coverUrl} height={height / 2.5} roundTopCorners={true}>
                <View style={[styles.header, { borderRadius: 10, borderColor: 'transparent'}]}>
                  <Image source={{ uri: avatarUrl }} style={styles.avatar} />
                </View>

                <View style={styles.bottomInfo}>
                  <View style={styles.userInfo}>
                    <Text style={[styles.userNameText, SHEET.baseText]}>
                    { displayName }
                  </Text>
                  </View>
                  <View style={{ right: 10 }}>
                    <View style={{ flex: 1 }}></View>
                    <View style={styles.serviceInfo}>
                      { serviceIcons }
                    </View>
                  </View>
                </View>
              </HeaderBanner>

              <View style={{ marginTop: -10, backgroundColor: 'white', height: 10 }} />

              <Card
                style={[{ marginBottom: 16}, styles.roundBottomCorners]}
                cardOverride={[{padding: 0}, styles.roundBottomCorners]}
                hideSeparator={true}
              >
                <View style={[styles.infoSection, SHEET.innerContainer]}>
                  {iconTextRow(require('../img/ic-mortar.png'), major)}
                  {iconTextRow(require('../img/ic-house.png'), hometown)}
                </View>

                <View style={styles.inCommonAndSeparatorContainer}>
                  <Text style={[SHEET.baseText, styles.inCommonText]}>In common:</Text>
                  <View style={[SHEET.separator, styles.separator]} />
                </View>

                { renderReasonSection(candidate, this.props.me, candidate.user) }

                <View style={{ marginHorizontal: 10, marginBottom: 10}}>
                  <CountdownTimer
                    style={{borderColor: 'white', borderBottomRightRadius: 5}}
                    navigator={this.props.navigator}
                    candidateUser={candidate.user} />
                </View>
              </Card>
            </View>
          </TouchableHighlight>
        </ScrollView>
      </View>
    )
  }
}

let avatarRadius = height / 4.5;

var styles = StyleSheet.create({
  card: {
    flex: 1,
    marginBottom: 10
  },
  cardOverride: {
    flex: 1,
    padding: 0,
  },
  roundBottomCorners: {
    borderBottomRightRadius: 5,
    borderBottomLeftRadius: 5,
    borderColor: 'transparent',
  },
  background: {
    position: 'absolute',
    left: 0,
    top: 0,
    width: width,
    height: height,
    alignItems: 'center',
    justifyContent: 'center',
  },
  backgroundQuoteText: {
    paddingTop: 15,
    fontSize: 20,
    color: COLORS.attributes,
    textAlign: 'center',
    marginHorizontal: width / 32,
  },
  avatar: {
    borderWidth: 2.5,
    borderColor: 'white',
    borderRadius: avatarRadius / 2,
    height: avatarRadius,
    width: avatarRadius,
  },
  header: {
    position: 'absolute',
    backgroundColor: 'rgba(0,0,0,0)',
    top: 0,
    left: 0,
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'center',
    width: width,
    height: height / 2.5,
  },
  userInfo: {
    flex: 1,
  },
  serviceInfo: {
    height: 42,
    justifyContent: 'center',
    flexDirection: 'row',
  },
  bottomInfo: {
    position: 'absolute',
    bottom: 0,
    width: width,
    flexDirection: 'row',
    backgroundColor: 'transparent',
    paddingHorizontal: width / 32,
    paddingVertical: 5,
  },
  userNameText: {
    color: 'white',
    fontSize: 24,
  },
  infoSection: {
    paddingBottom: 10,
  },
  messageButton: {
    height: 40,
    justifyContent: 'center',
    alignItems: 'center',
    flexDirection: 'row',
    marginHorizontal: width / 32,
    backgroundColor: COLORS.button,
    marginBottom: 10,
    borderRadius : 3,
  },
  messageButtonText: {
    paddingLeft: width / 64,
    fontSize: 18,
    color: COLORS.white,
  },
  headerText: {
    color: COLORS.white,
    fontSize: 24
  },
  serviceIcon: {
    marginRight: 5,
  },
  inCommonAndSeparatorContainer: {
    flex: 1,
    flexDirection: 'row',
    paddingHorizontal: 10
  },
  inCommonText: {
    fontSize: 14,
  },
  separator: {
    flex: 1,
    marginTop: 3,
    alignSelf: 'center',
    marginLeft: 10,
  },
});

export default connect(mapStateToProps)(DiscoverScreen)
