let React = require('react-native');
let TaylrAPI = require('react-native').NativeModules.TaylrAPI;

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
let { width } = Dimensions.get('window');

let Card = require('./Card').Card;
let HeaderBanner = require('./HeaderBanner');
let COLORS = require('./CommonStyles').COLORS;
let SHEET = require('./CommonStyles').SHEET;
let ddp = require('../lib/ddp');

class ActivityHeader extends React.Component {
  render() {
    let me = this.props.me;
    return (
      <HeaderBanner url={me.cover.url} height={200}>
        <View style={styles.activityUser}>
          <Image source={{ uri: me.avatar.url }} style={SHEET.bigIconCircle} />
          <Text style={styles.activityUserTitle}>
            {me.firstName} {me.lastName} {me.gradYear}
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

    var source = null;
    var header = null;
    let profile = connectedProfiles[activity.profileId]
    if (profile) {
      source = (
        <View style={[{ paddingBottom: 10 }, styles.activityElement]}>
          <Text style={[SHEET.baseText]}>
            via <Text style={{fontWeight: 'bold', color: profile.themeColor }}>
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
            <Text style={ SHEET.subTitle }>
              { this._timeDifference(new Date(), activity.timestamp) }
            </Text>
          </View>
        </View>
      )
    }

    return (
      <Card
        style={styles.card}
        cardOverride={{ padding: 0 }}>
          {header}
          {image}
          {caption}
          <View style={styles.activityElement}>
            <Text style={SHEET.baseText}>{activity.text}</Text>
          </View>
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
    if (this.props.profile) {
      let sourceMap = this.props.profile.integrationName == this.props.activeProfile ? 
        this.props.iconMapping :
        this.props.grayToIconMapping;

      source = { uri: sourceMap[this.props.profile.integrationName] };
    } else {
      source = this.props.activeProfile === 'taylr' ? 
        require('./img/ic-taylr-colored.png') :
        require('./img/ic-taylr-gray.png');
    }

    return (
      <TouchableOpacity onPress={() => {
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
      activities: [],
    }
  }

  componentWillMount() {
    let subscriptionId = ddp.subscribe('activities', [this.props.me._id])
    .then((subscriptionId) => {
      this.setState({ subscriptionId: subscriptionId });
    })

    let observer = ddp.collections.observe(() => {
      if (ddp.collections.activities) {
        return ddp.collections.activities.find({});
      }
    }).subscribe((results) => {
      if (results) {
        console.log(results.length);
        results.sort((one, two) => {
          return two.timestamp - one.timestamp;
        })
        this.setState({ activities: results });
      }
    })
  }

  componentWillUnmount() {
    ddp.unsubscribe(this.state.subscriptionId);
  }

  _switchService(profile) {
    let results = ddp.collections.activities.find({ profileId: profile.id });
    results.sort((one, two) => {
      return two.timestamp - one.timestamp;
    });

    let newState = {
      activities: results,
      activeProfile: profile.integrationName,
      displayTaylrInfo: false,
    };

    this.setState(newState);
  }

  _switchToTaylr() {
    // clear activity cards
    this.setState({ 
      activities: [],
      activeProfile: 'taylr',
      displayTaylrInfo: true,
    });
  }

  render() {
    if (!this.state.activities) {
      return <Text>Loading ... </Text>
    }

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

    let connectedProfiles = {};
    let profiles = me.connectedProfiles.map(profile => {
      connectedProfiles[profile.id] = profile;

      let source = this.state[profile._id] ?
        iconMapping[profile.integrationName] :
        grayToIconMapping[profile.integrationName];

      return <ActivityServiceIcon 
        onPress={this._switchService.bind(this)}
        activeProfile={this.state.activeProfile}
        profile={profile}
        iconMapping={iconMapping}
        grayToIconMapping={grayToIconMapping} />
    })

    let activities = this.state.activities.map((activity) => {
      return <Activity
        me={me}
        connectedProfiles={connectedProfiles}
        activity={activity} /> 
    })

    let taylrInfo = null;
    if (this.state.displayTaylrInfo) {
      taylrInfo = (
        <Card style={styles.card}>
          <Text style={[SHEET.smallHeading, SHEET.subTitle, SHEET.baseText]}>About Me</Text>
          <Text>{me.about}</Text>
        </Card> 
      ) 
    }

    return (
      <View style={SHEET.container}>
        <ScrollView style={[SHEET.navTop, SHEET.bottomTilex]}>
          <ActivityHeader me={me} />

          <Card
            style={{ flex: 1, flexDirection: 'column', alignItems: 'center' }}
            cardOverride={{ padding: 10 }}
            hideSeparator={true}>
            <ScrollView
              horizontal={true}>
                <ActivityServiceIcon 
                  onPress={this._switchToTaylr.bind(this)}
                  activeProfile={this.state.activeProfile}
                  source={require('./img/ic-taylr-gray.png')} />
                {profiles}
            </ScrollView>
          </Card>

          <View style={SHEET.innerContainer}>
            { taylrInfo }
            { activities }
            <View style={SHEET.bottomTile} />
          </View>
        </ScrollView>
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
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'rgba(0,0,0,0)',
    top: 0,
    left: 0,
    height: 200,
    width: width,
  },
  activityUserTitle: {
    paddingTop: 10,
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
});

module.exports = Activities;