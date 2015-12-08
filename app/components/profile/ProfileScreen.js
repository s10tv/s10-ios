import React, {
  Dimensions,
  Text,
  Image,
  ScrollView,
  TouchableOpacity,
  View,
  PropTypes,
  StyleSheet,
} from 'react-native';

import { connect } from 'react-redux/native';
import { SCREEN_PROFILE } from '../../constants';
import Screen from '../Screen';

import { Card } from '../lib/Card';
import HeaderBanner from '../lib/HeaderBanner';
import { COLORS, SHEET } from '../../CommonStyles';
import Loader from '../lib/Loader';
import iconTextRow from '../lib/iconTextRow';
import CountdownTimer from '../lib/CountdownTimer';

const logger = new (require('../../../modules/Logger'))('ProfileScreen');
const { height, width } = Dimensions.get('window');

function mapStateToProps(state) {
  return {
    ddp: state.ddp,
  }
}

class ActivityHeader extends React.Component {
  render() {
    let me = this.props.me;

    let coverUrl = 'https://s10tv.blob.core.windows.net/s10tv-prod/defaultbg.jpg';
    if (me && me.cover && me.cover.url) {
      coverUrl = me.cover.url;
    }

    return (
      <HeaderBanner url={ coverUrl } height={ height / 3 }>
        <View style={[ { height: height / 3, top: height / 12 }, styles.activityUser]}>
          <Image source={{ uri: me.avatarUrl }} style={{ width: height / 6, height: height / 6,
              borderRadius: height / 12, borderColor: 'white', borderWidth: 2.5 }} />
          <Text style={[{ marginTop: height / 96}, styles.activityUserTitle, SHEET.baseText]}>
            {me.longDisplayName}
          </Text>
        </View>
      </HeaderBanner>
    )
  }
}

class Activity extends React.Component {

  _timeDifference(current, previous) {
    var msPerMinute = 60 * 1000;
    var msPerHour = msPerMinute * 60;
    var msPerDay = msPerHour * 24;
    var msPerWeek = msPerDay * 7;

    var elapsed = current - previous;

    if (elapsed < msPerHour) {
      return Math.round(elapsed/msPerMinute) + 'm';
    }

    else if (elapsed < msPerDay ) {
      return Math.round(elapsed/msPerHour ) + 'h';
    }

    else if (elapsed < msPerWeek) {
      return Math.round(elapsed/msPerDay) + 'd';
    }

    else {
      return Math.round(elapsed/msPerWeek) + 'w';
    }
  }

  render() {
    let activity = this.props.activity;
    let me = this.props.me;
    let connectedProfiles = this.props.connectedProfiles;
    let isHidden = this.props.activeProfile.id != activity.profileId;

    if (isHidden) {
      return null;
    }

    var image = null;
    if (activity.image) {
      image = <Image style={[{ height: 300}, styles.activityImage]}
        source={{ uri: activity.image.url }} />
    }

    var caption = null;
    if (activity.caption) {
      caption = (
        <View style={[styles.activityElement, styles.caption]}>
          <Text style={[SHEET.subTitle, SHEET.baseText]}>{activity.caption}</Text>
        </View>
      )
    }

    var text = null;
    if (activity.text) {
      text = (
        <View style={styles.activityElement}>
          <Text style={SHEET.baseText}>{activity.text}</Text>
        </View>
      )
    }

    var source = null;
    var header = null;
    let profile = connectedProfiles[activity.profileId]
    if (profile) {
      source = (
        <View style={[{ paddingBottom: 10 }, styles.activityElement]}>
          <Text style={[SHEET.baseText]}>
            via <Text style={[{fontWeight: 'bold', color: profile.themeColor }, SHEET.baseText]}>
              {profile.integrationName}
            </Text>
          </Text>
        </View>
      )

      header = (
        <View style={[ styles.activityHeader, SHEET.row]}>
          <Image source={{ uri: profile.avatar.url }}
            style={[{ marginRight: 5}, SHEET.iconCircle]} />
          <View style={{ flex: 1 }}>
            <Text style={SHEET.baseText}>{profile.displayId}</Text>
          </View>
          <View style={{ width: 32 }}>
            <Text style={ [SHEET.subTitle, SHEET.baseText] }>
              { this._timeDifference(new Date(), activity.timestamp) }
            </Text>
          </View>
        </View>
      )
    }

    return (
      <Card
        key={activity._id}
        style={styles.card}
        cardOverride={{ padding: 0 }}>
          {header}
          {image}
          {caption}
          {text}
          {source}
      </Card>
    )
  }
}

class ActivityServiceIcon extends React.Component {

  constructor(props) {
    super(props)
    this.state = {
      color: false
    }
  }

  render() {
    let source = null;

    // TODO: Can use tint color here.
    if (this.props.profile) {
      let sourceMap = this.props.profile.integrationName == this.props.activeProfile.integrationName ?
        this.props.iconMapping :
        this.props.grayToIconMapping;

      source = { uri: sourceMap[this.props.profile.integrationName] };
    } else {
      source = this.props.activeProfile.integrationName === 'taylr' ?
        require('../img/ic-taylr-colored.png') :
        require('../img/ic-taylr-gray.png');
    }

    return (
      <TouchableOpacity
      {...this.props}
      onPress={() => {
        this.setState({ color: !this.state.color })
        this.props.onPress(this.props.profile)}
      }>
        <Image
            style={[SHEET.iconCircle, { marginHorizontal: 5}]}
            source={source} />
      </TouchableOpacity>
    )
  }
}

class ProfileScreen extends Screen {

  static id = SCREEN_PROFILE;

  static propTypes = {
    isFromDiscoveryScreen: PropTypes.bool,
    isFromHistoryScreen: PropTypes.bool,
  }

  constructor(props) {
    super(props);
    this.state = {
      activeProfile: { id: 'taylr', integrationName: 'taylr' }
    };
  }

  _switchService(profile) {
    let newState = {
      activeProfile: profile,
    };

    this.setState(newState);
  }

  _switchToTaylr() {
    // clear activity cards
    this.setState({
      activeProfile: { id: 'taylr', integrationName: 'taylr' },
    });
  }

  componentWillMount() {
    let ddp = this.props.ddp;
    ddp.subscribe({ pubName: 'activities', params: [this.props.userId] })
    .then(() => {
      ddp.collections.observe(() => {
        if (ddp.collections.activities) {
          return ddp.collections.activities.find({ userId: this.props.userId });
        }
      }).subscribe(activities => {
        this.setState({ activities: activities });
      });
    })
  }

  render() {
    // This is because on the fly grayscale is not ready in RN yet.
    let grayToIconMapping = {
      facebook: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-facebook-gray.png',
      instagram: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-instagram-gray.png',
      github: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-github-gray.png',
      twitter: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-twitter-gray.png',
      soundcloud: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-soundcloud-gray.png'
    };

    let iconMapping = {
      facebook: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-facebook.png',
      instagram: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-instagram.png',
      github: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-github.png',
      twitter: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-twitter.png',
      soundcloud: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-soundcloud.png'
    };

    let profileUserId = this.props.userId;

    // TODO(qimingfang): should not be using private methods like this.
    let user = this.props.ddp._formatUser(
      this.props.ddp.collections.users.findOne({ _id: profileUserId }));

    if (!user) {
      return <Loader />
    }

    let connectedProfiles = {};

    let profiles = null;
    if (user.connectedProfiles) {
      profiles = user.connectedProfiles.map(profile => {
        connectedProfiles[profile.id] = profile;

        let source = this.state[profile._id] ?
          iconMapping[profile.integrationName] :
          grayToIconMapping[profile.integrationName];

        return <ActivityServiceIcon
          key={profile.id}
          onPress={this._switchService.bind(this)}
          activeProfile={this.state.activeProfile}
          profile={profile}
          iconMapping={iconMapping}
          grayToIconMapping={grayToIconMapping} />
      })
    }

    var activityData = null;
    if (this.props.activities) {
      activityData = this.props.activities;
    } else if (this.state.activities) {
      activityData = this.state.activities;
    } else {
      activityData = [];
    }

    activityData.sort((one, two) => {
      return two.timestamp - one.timestamp;
    })

    let activities = activityData.map((activity) => {
      return <Activity
        key={activity._id}
        me={user}
        connectedProfiles={connectedProfiles}
        activeProfile={this.state.activeProfile}
        activity={activity} />
    })

    let infoCard = null;
    if (this.state.activeProfile.id == 'taylr') {
      infoCard = (
        <Card style={styles.card}>
          <View style={{ marginBottom: 10 }}>
            {iconTextRow(require('../img/ic-mortar.png'), user.major)}
            {iconTextRow(require('../img/ic-house.png'), user.hometown)}
          </View>
          <View style={SHEET.separator} />

          <View style={{ marginTop: 10 }}>
            <Text style={[SHEET.smallHeading, SHEET.subTitle, SHEET.baseText]}>About {user.firstName}</Text>
            <Text stlye={[SHEET.baseText]}>{user.about}</Text>
          </View>
        </Card>
      )
    } else {
      profile = connectedProfiles[this.state.activeProfile.id]
      attributes = null
      if (profile && profile.attributes) {
        attributes = profile.attributes.map((attribute) => {
          return (
            <View key={attribute.label} style={styles.attributeBox}>
              <Text style={[SHEET.baseText, styles.attributeText]}>{attribute.value}</Text>
              <Text style={[SHEET.baseText, styles.attributeText]}>{attribute.label}</Text>
            </View>
          )
        });
      }

      let separator = (attributes && attributes.length > 0) ?
        <View style={SHEET.separator} /> :
        null;

      infoCard = (
        <Card style={styles.card}>
          <View style={styles.horizontal}>
            <Image style={styles.infoAvatar} source={{ uri: profile.avatar.url }} />
            <View style={{flex: 1, left: 10, top: 5}}>
              <Text style={[SHEET.baseText, SHEET.smallHeading]}>{ `${user.firstName} ${ user.lastName}`}</Text>
              <Text style={[SHEET.baseText, SHEET.subTitle]}>{ profile.displayName }</Text>
            </View>
            <TouchableOpacity style={[styles.openButton]}
              onPress={() => this.props.navigator.push({
                id: 'viewintegration',
                url: profile.url,
                integration: profile,
              })}>
                <Text style={[{fontSize: 18, color: COLORS.white }, SHEET.baseText]}>Open</Text>
            </TouchableOpacity>
          </View>
          { separator }
          <ScrollView horizontal={true}
            showsHorizontalScrollIndicator={false}
            style={{ marginHorizontal: 10 }}>
            { attributes }
          </ScrollView>
        </Card>
      )
    }

    let messageButton = null;
    if (this.props.isFromDiscoveryScreen || this.props.isFromHistoryScreen) {

      let overrideText = null;
      if (this.props.isFromHistoryScreen) {
        overrideText = `Message ${user.firstName}`;
      }

      messageButton = (
        <CountdownTimer
          style={styles.messageButton}
          navigator={this.props.navigator}
          overrideText={overrideText}
          candidateUser={user} />
      )
    }

    return (
      <View style={SHEET.container}>
        <ScrollView showsVerticalScrollIndicator={false}>
          <ActivityHeader me={user} />

          <Card
            style={{ flex: 1, flexDirection: 'column', alignItems: 'center' }}
            cardOverride={{ padding: 10 }}
            hideSeparator={true}>
            <ScrollView
              showsHorizontalScrollIndicator={false}
              horizontal={true}>
                <ActivityServiceIcon
                  onPress={this._switchToTaylr.bind(this)}
                  activeProfile={this.state.activeProfile}
                  source={require('../img/ic-taylr-gray.png')} />
                {profiles}
            </ScrollView>
          </Card>

          <View style={SHEET.innerContainer}>
            { infoCard }
            { activities }
            <View style={SHEET.bottomTile} />
          </View>
        </ScrollView>

        { messageButton }
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
