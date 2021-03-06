import React, {
  Dimensions,
  Text,
  Image,
  ListView,
  InteractionManager,
  TouchableOpacity,
  View,
  LinkingIOS,
  PropTypes,
  StyleSheet,
} from 'react-native';

import { connect } from 'react-redux/native';

import { renderCommonSection } from './renderCommonSection';
import renderMyCourses from './renderMyCourses';
import renderAboutMe from './renderAboutMe';
import HashtagCategory from '../lib/HashtagCategory';
import editPhotoHeader from '../lib/editPhotoHeader';
import EditProfileOverlay from './EditProfileOverlay';
import MoreCard from './MoreCard';

import { Card } from '../lib/Card';
import HeaderBanner from '../lib/HeaderBanner';
import sectionTitle from '../lib/sectionTitle';
import { COLORS, SHEET } from '../../CommonStyles';
import Loader from '../lib/Loader';
import iconTextRow from '../lib/iconTextRow';
import CountdownTimer from '../lib/CountdownTimer';
import BridgeManager from '../../../modules/BridgeManager';
import SoundcloudActivity from '../lib/SoundcloudActivity'
const logger = new (require('../../../modules/Logger'))('ProfileScreen');
const { height, width } = Dimensions.get('window');

import renderActivityHeader from './renderActivityHeader';
import renderServiceIconsBanner from './renderServiceIconsBanner';
import renderActivity from './renderActivity';
import renderProfileIntroCard from './renderProfileIntroCard';

function mapStateToProps(state) {
  return {
    me: state.me,
    ddp: state.ddp,
    apphub: state.apphub,
    categories: state.categories,
    myTags: state.myTags,
  }
}

class ProfileScreen extends React.Component {

  static propTypes = {
    isFromDiscoveryScreen: PropTypes.bool,
    isFromHistoryScreen: PropTypes.bool,
    isFromCoursesView: PropTypes.bool,
    isFromMeScreen: PropTypes.bool,
    isEditable: PropTypes.bool,
  }

  constructor(props) {
    super(props);
    this.state = {
      activities: [],
      dataSource: new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2}),
      activeProfileName: 'taylr',
      activeProfileId: 'taylr',
      isEditingMe: false,
    };
  }

  _switchProfile(profile) {
    this.setState({
      activeProfileId: profile.id,
      activeProfileName: profile.integrationName,
    });

    InteractionManager.runAfterInteractions(() => {
      this._updateActivities(profile.integrationName)
    })
  }

  _updateActivities() {
    const filteredActivities = this.props.ddp.collections.activities.find({
      profileId: this.state.activeProfileId
    })

    this.setState({
      dataSource: this.state.dataSource.cloneWithRows(filteredActivities),
    })
  }

  _pressEditMe() {
    this.setState({ isEditingMe: true });
  }

  _closeEditMe() {
    this.setState({ isEditingMe: false });
  }

  componentWillMount() {
    let userId;
    if (this.props.userId) {
      userId = this.props.userId;
    } else if (this.props.user) {
      userId = this.props.user._id
    }

    if (userId) {
      this.props.ddp.subscribe({ pubName: 'activities', params: [userId] })
      .then((subId) => {
        this.subId = subId;
      })

    } else {
      logger.warning(`Subscribing to profiile with no userId`);
    }
  }

  componentWillUnmount() {
    if (this.subId) {
      this.props.ddp.unsubscribe(this.subId);
    }
  }

  renderHeader({ user, serviceIconProfiles, connectedProfiles, isEditable = false }) {
    const hashtagCategories = !isEditable ? null : (
      <View style={SHEET.innerContainer}>
        { sectionTitle('MY TAGS') }
        <HashtagCategory
          myTags={this.props.myTags}
          categories={this.props.categories}
          navigator={this.props.navigator} />
      </View>
    )

    let summaryCard;
    if (this.state.activeProfileName == 'taylr') {
      const inCommonCard = this.props.isFromMeScreen && isEditable ?  null : (
        <View style={SHEET.innerContainer}>
          { renderCommonSection(this.props.me, user) }
        </View>
      )


      const moreCard = !this.props.isFromMeScreen ? null : (
        <View style={SHEET.innerContainer}>
          { sectionTitle('MORE') }
          <MoreCard
            navigator={this.props.navigator}
            onFetchCourses={this.props.onFetchCourses}
            shouldShowUpgradeCard={this.props.shouldShowUpgradeCard}
            upgrade={this.props.upgrade}
            onPressLogout={this.props.onPressLogout} />
        </View>
      )

      summaryCard = (
        <View>
          { inCommonCard }
          { renderAboutMe({ user, isEditable, onPressEdit: this._pressEditMe.bind(this)}) }
          { renderMyCourses({
            courses: user.courses,
            navigator: this.props.navigator,
            onRemoveCourse: this.props.onRemoveCourse,
            isEditable})
          }

          { hashtagCategories }

          { moreCard }
        </View>
      )
    } else {
      summaryCard = renderProfileIntroCard({
        navigator: this.props.navigator,
        activeProfile: this.state.activeProfileName,
        me: this.props.me,
        connectedProfiles,
        user,
      });
    }

    let header;
    if (isEditable) {
      header = editPhotoHeader(
        this.props.onUploadImage,
        this.props.me.avatarUrl,
        this.props.me.coverUrl
      )
    } else {
      header = renderActivityHeader(user);
    }


    return (
      <View>
        { header }
        { renderServiceIconsBanner({
          navigator: this.props.navigator,
          profiles: serviceIconProfiles,
          activeProfile: this.state.activeProfileName,
          onPress: this._switchProfile.bind(this),
          isEditable})
        }

        { summaryCard }
      </View>
    )
  }

  renderMessageButton(user) {
    if (this.props.isFromDiscoveryScreen ||
        this.props.isFromHistoryScreen ||
        this.props.isFromCoursesView) {

      let overrideText = null;
      if (this.props.isFromHistoryScreen || this.props.isFromCoursesView) {
        overrideText = `Message ${user.firstName}`;
      }

      return (
        <CountdownTimer
          style={styles.messageButton}
          navigator={this.props.navigator}
          overrideText={overrideText}
          candidateUser={user} />
      )
    }

    return null;
  }

  render() {
    let user;
    if (this.props.userId) {
      user = this.props.ddp._formatUser(
        this.props.ddp.collections.users.findOne({ _id: this.props.userId }));
    } else if (this.props.user) {
      user = this.props.user;
    }

    if (!user) {
      return <Loader />
    }

    // index by id and add to serviceIconList
    const serviceIconProfiles = [{ integrationName: 'taylr' }]; // default with Taylr
    const connectedProfilesById = {};
    const connectedProfilesByName = {};
    user.connectedProfiles.forEach(profile => {
      serviceIconProfiles.push(profile);
      connectedProfilesById[profile.id] = profile
      connectedProfilesByName[profile.integrationName] = profile
    });

    const overlay = !this.props.isEditable ? null : (
      <EditProfileOverlay
        isVisible={this.state.isEditingMe}
        hideModal={this._closeEditMe.bind(this)} />
    )

    return (
      <View style={SHEET.container}>
        { overlay }
        <ListView
          dataSource={this.state.dataSource}
          renderHeader={() => { return this.renderHeader({
            user,
            serviceIconProfiles,
            connectedProfiles: connectedProfilesByName,
            isEditable: this.props.isEditable })}}

          renderRow={(activity) => { return renderActivity(activity, connectedProfilesById) }}
          renderFooter={() => {
            if (this.props.isEditable) {
              return (
                <View style={styles.versionTextContainer}>
                  <Text style={[styles.versionText, SHEET.innerContainer, SHEET.baseText]}>
                    { `v${BridgeManager.version()} | ${BridgeManager.build()}` +
                     ` | AH: ${this.props.apphub.buildName}` }
                  </Text>
                </View>
              )
            } else {
              return <View style={{ paddingBottom: 64}} />
            }
          }}
        />
        {this.renderMessageButton(user)}
      </View>
    )
  }
}

var styles = StyleSheet.create({
  activityElement: {
    flex: 1,
    paddingTop: 10,
    paddingHorizontal: 10,
  },
  activityUser: {
    flex: 1,
    position: 'absolute',
    alignItems: 'center',
    backgroundColor: 'rgba(0,0,0,0)',
    left: 0,
    width: width,
  },
  activityUserTitle: {
    fontSize: 22,
    color: COLORS.white,
  },
  activityHeader: {
    paddingTop: 12,
    paddingBottom: 8,
    paddingHorizontal: 10
  },
  card: {
    flex: 1,
    marginTop: 8,
  },
  horizontal: {
    flex: 1,
    flexDirection: 'row',
    paddingBottom: 10,
  },
  infoAvatar: {
    width: 60,
    height: 60,
    borderRadius: 30,
  },
  openButton: {
    marginTop: 10,
    width: 60,
    height: 36,
    borderRadius: 3,
    paddingBottom: 3,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#327BEE',
  },
  attributeBox: {
    marginHorizontal: 15,
    paddingHorizontal: 10,
    paddingTop: 10,
    justifyContent: 'center',
    alignItems: 'center',
  },
  attributeText: {
    fontSize: 20,
    color: COLORS.attributes,
  },
  caption: {
    marginTop: 10,
    marginLeft: 7,
    paddingLeft: 7,
    borderLeftWidth: 1,
    borderLeftColor: COLORS.background,
  },
  activityImage: {
    flex: 1,
    resizeMode: 'cover',
  },
  messageButton: {
    position: 'absolute',
    bottom: 0,
    width: width,
    height: 50,
    marginHorizontal: 0,
    borderRadius : 0,
  },
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

export default connect(mapStateToProps)(ProfileScreen)
