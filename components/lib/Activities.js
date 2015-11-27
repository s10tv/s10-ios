let React = require('react-native');

let {
  AppRegistry,
  Text,
  Image,
  ScrollView,
  TouchableOpacity,
  View,
  StyleSheet,
} = React;

let Dimensions = require('Dimensions');
let { height, width } = Dimensions.get('window');

let Analytics = require('../../modules/Analytics');
let Card = require('./Card').Card;
let HeaderBanner = require('./HeaderBanner');
let COLORS = require('../CommonStyles').COLORS;
let SHEET = require('../CommonStyles').SHEET;
let IconTextRow = require('../lib/IconTextRow');
let Loader = require('../lib/Loader');
let CountdownTimer = require('../lib/CountdownTimer');

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
          <Image source={{ uri: me.avatar.url }} style={{ width: height / 6, height: height / 6,
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

class Activities extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      activeProfile: { id: 'taylr', integrationName: 'taylr' }
    };
  }

  _switchService(profile) {
    Analytics.track('Profile: Switch', {
      name: profile.integrationName
    });

    let newState = {
      activeProfile: profile,
    };

    this.setState(newState);
  }

  _switchToTaylr() {
    Analytics.track('Profile: Switch', {
      name: 'taylr' 
    });

    // clear activity cards
    this.setState({
      activeProfile: { id: 'taylr', integrationName: 'taylr' },
    });
  }

  componentWillMount() {
    let ddp = this.props.ddp;
    if (this.props.loadActivities) {
      ddp.subscribe({ pubName: 'activities', params: [this.props.me._id] })
      .then(() => {
        ddp.collections.observe(() => {
          if (ddp.collections.activities) {
            return ddp.collections.activities.find({ userId: this.props.me._id });
          }
        }).subscribe(activities => {
          this.setState({ activities: activities });
        }); 
      })
    } 
  }

  render() {
    // This is because on the fly grayscale is not ready in RN yet.
    let grayToIconMapping = {
      facebook: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-facebook-gray.png',
      instagram: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-instagram-gray.png',
      github: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-github-gray.png',
      twitter: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-twitter-gray.png',
    };

    let iconMapping = {
      facebook: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-facebook.png',
      instagram: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-instagram.png',
      github: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-github.png',
      twitter: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-twitter.png',
    };

    let me = this.props.me;

    if (!me) {
      return <Loader />
    }

    let connectedProfiles = {};
    let profiles = me.connectedProfiles.map(profile => {
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
        me={me}
        connectedProfiles={connectedProfiles}
        activeProfile={this.state.activeProfile}
        activity={activity} /> 
    })

    let infoCard = null;
    if (this.state.activeProfile.id == 'taylr') {
      infoCard = (
        <Card style={styles.card}>
          <View style={{ marginBottom: 10 }}>
            <IconTextRow
              style={{ paddingVertical: 5 }}
              icon={require('../img/ic-mortar.png')}
              text={me.major} />
            <IconTextRow
              style={{ paddingVertical: 5 }}
              icon={require('../img/ic-house.png')}
              text={me.hometown} />
          </View>
          <View style={SHEET.separator} />

          <View style={{ marginTop: 10 }}>
            <Text style={[SHEET.smallHeading, SHEET.subTitle, SHEET.baseText]}>About Me</Text>
            <Text stlye={[SHEET.baseText]}>{me.about}</Text>
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
              <Text style={[SHEET.baseText, SHEET.smallHeading]}>{ `${me.firstName} ${ me.lastName}`}</Text>
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
    if (this.props.isCurrentCandidate && this.props.currentUser && 
        this.props.candidateUser) {
      messageButton = (
        <CountdownTimer
          style={styles.messageButton}
          track={() => {
            Analytics.track('Profile: TapMessage')
          }}
          navigator={this.props.navigator}
          candidateUser={this.props.candidateUser}
          me={this.props.me}
          settings={this.props.settings} />
      )
    }

    return (
      <View style={SHEET.container}>
        <ScrollView showsVerticalScrollIndicator={false}>
          <ActivityHeader me={me} />

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

module.exports = Activities;