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
import { SCREEN_PROFILE } from '../../constants';
import Screen from '../Screen';

import renderCommonSection from './renderCommonSection';
import { Card } from '../lib/Card';
import HeaderBanner from '../lib/HeaderBanner';
import sectionTitle from '../lib/sectionTitle';
import { COLORS, SHEET } from '../../CommonStyles';
import Loader from '../lib/Loader';
import iconTextRow from '../lib/iconTextRow';
import CountdownTimer from '../lib/CountdownTimer';
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
  }
}

class ProfileScreen extends Screen {

  static propTypes = {
    isFromDiscoveryScreen: PropTypes.bool,
    isFromHistoryScreen: PropTypes.bool,
  }

  constructor(props) {
    super(props);
    this.state = {
      activities: [],
      dataSource: new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2}),
      activeProfileName: 'taylr',
      activeProfileId: 'taylr',
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

  renderHeader(user, serviceIconProfiles, connectedProfiles) {
    return (
      <View>
        { renderActivityHeader(user) }
        { renderServiceIconsBanner(
          serviceIconProfiles,
          this.state.activeProfileName,
          this._switchProfile.bind(this)) }
        { renderProfileIntroCard(
          this.props.navigator,
          user,
          this.state.activeProfileName,
          connectedProfiles,
          this.props.me)}
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

    return (
      <View style={SHEET.container}>
        <ListView
          dataSource={this.state.dataSource}
          renderHeader={() => { return this.renderHeader(user, serviceIconProfiles, connectedProfilesByName)}}
          renderRow={(activity) => { return renderActivity(activity, connectedProfilesById) }}
          renderFooter={() => {
            if (this.props.isFromDiscoveryScreen || this.props.isFromHistoryScreen) {
              return <View style={{ paddingBottom: 64 }} />
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
  }
});

export default connect(mapStateToProps)(ProfileScreen)
