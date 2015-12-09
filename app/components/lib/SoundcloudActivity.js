'use strict'

var React = require('react-native');
var {
  StyleSheet,
  View,
  Text,
  Image,
} = React;

require('moment-duration-format');
var moment = require('moment');
var numeral = require('numeral')
let Dimensions = require('Dimensions');
let { height, width } = Dimensions.get('window');

let COLORS = require('../../CommonStyles').COLORS;
let SHEET = require('../../CommonStyles').SHEET;
let Card = require('./Card').Card;

class SoundcloudActivity extends React.Component {

  _300x300imageFromURL(url) {
    return url.replace('large', 't300x300')
  }

  _formatPlaybackCount(count) {
    return numeral(count).format('0.0a').replace('.0', '');
  }

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

    var track = null;
    if (activity.type == 'playlist') {
      if (activity.attributes.author && activity.attributes.title && activity.attributes.artwork.url) {
        track = (
          <View style={styles.trackContainer}>
            <Image style={styles.artwork} source = {{ uri: this._300x300imageFromURL(activity.attributes.artwork.url) }}/>
            <View style={[styles.genericTextContainer, styles.playlistTextContainer]}>
              <View style={styles.trackHeaderContainer}>
                <Text style={[SHEET.baseText, styles.trackHeaderText]}>{activity.attributes.author}</Text>
                <Text style={[SHEET.baseText, styles.trackHeaderText]}>{moment.duration(activity.attributes.duration).format()}</Text>
              </View>
              <Text style={[SHEET.baseText, styles.trackTitleText, styles.playlistTitleText]}>{activity.attributes.title}</Text>
            </View>
          </View>
        )
      }
    } else {
      if (activity.attributes.author && activity.attributes.title && activity.attributes.artwork.url) {
        track = (
          <View style={styles.trackContainer}>
            <Image style={styles.artwork} source = {{ uri: this._300x300imageFromURL(activity.attributes.artwork.url) }} />
            <View style={[styles.genericTextContainer, styles.trackTextContainer]}>
              <View style={styles.trackHeaderContainer}>
                <Text style={[SHEET.baseText, styles.trackHeaderText]}>{activity.attributes.author}</Text>
                <Text style={[SHEET.baseText, styles.trackHeaderText]}>{moment.duration(activity.attributes.duration).format()}</Text>
              </View>
              <Text style={[SHEET.baseText, styles.trackTitleText]}>{activity.attributes.title}</Text>
              <View style={styles.trackFooterContainer}>
                <Image style={styles.playcountIcon} source={require('../img/ic-soundcloud-playcount.png')}/>
                <Text style={[SHEET.baseText, styles.trackFooterText]}>{this._formatPlaybackCount(activity.attributes.playbackCount)}</Text>
              </View>
            </View>
          </View>
        )
      }
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
          {track}
          {caption}
          {text}
          {source}
      </Card>
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
  caption: {
    marginTop: 5,
    marginLeft: 10,
    paddingLeft: 7,
    borderLeftWidth: 1,
    borderLeftColor: COLORS.background,
  },
  activityImage: {
    flex: 1,
    resizeMode: 'stretch',
  },

  trackContainer: {
    flex: 1,
    margin: 10,
    padding: 10,
    flexDirection: 'row',
    backgroundColor: '#EEEEEE',
  },
  trackHeaderContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  genericTextContainer: {
    flex: 1,
    flexDirection: 'column',
    height: 75,
    paddingLeft: 10,
  },
  trackTextContainer: {
    justifyContent: 'space-between',
  },
  trackFooterContainer: {
    flexDirection: 'row',
  },

  trackHeaderText: {
    color: '#9B9B9B',
    fontSize: 10,
  },
  trackTitleText: {
    fontSize: 12,
  },
  playlistTitleText: {
    marginTop: 10,
  },
  trackFooterText: {
    color: '#9B9B9B',
    fontSize: 9,
    marginLeft: 5,
  },

  artwork: {
    width: 75,
    height: 75,
  },
  playcountIcon: {
    alignSelf: 'center',
  },
});

module.exports = SoundcloudActivity;
