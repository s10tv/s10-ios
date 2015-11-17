let React = require('react-native');
let Button = require('react-native-button');

let {
  AppRegistry,
  View,
  ScrollView,
  Text,
  Image,
  TouchableOpacity,
  TouchableHighlight,
  ActionSheetIOS,
  Navigator,
  StyleSheet,
} = React;

let Dimensions = require('Dimensions');
let { width, height } = Dimensions.get('window');

let SHEET = require('../CommonStyles').SHEET;
let COLORS = require('../CommonStyles').COLORS;
let HeaderBanner = require('../lib/HeaderBanner');
let Card = require('../lib/Card').Card;

class IconTextRow extends React.Component {
  render() {
    return (
      <View style={iconTextRowStyles.row}>
        <Image source={this.props.icon} />
        <Text style={[iconTextRowStyles.text, SHEET.baseText]}>{this.props.text}</Text>
      </View>
    )
  }
}

var iconTextRowStyles = StyleSheet.create({
  row: {
    flexDirection: 'row',
    padding: 5,
  },
  text: {
    marginLeft: 10, 
  }
});

class CountdownTimer extends React.Component {
  constructor(props) {
    super(props); 
    this.state = {
      countdown: '...'
    }
  }

  componentWillMount() {
    let format = function(num) {
      return ("0" + num).slice(-2);
    }

    let timerFunction = function() {
      let settings = this.props.settings;
      if (!settings || !settings.nextMatchDate) {
        return;
      }

      let nextMatchDate = Math.floor(settings.nextMatchDate.value.getTime() / 1000);
      let now = Math.floor(new Date().getTime() / 1000);

      let interval = Math.max(nextMatchDate - now, 0)
      let hours = Math.floor(interval / 3600);
      let minutes = Math.floor((interval - hours * 3600) / 60);
      let seconds = Math.floor((interval - hours * 3600) - minutes * 60);

      this.setState({ countdown: `${format(hours)}:${format(minutes)}:${format(seconds)}`});
    }

    timerFunction.bind(this)();
    this.setState({ timer: setInterval(timerFunction.bind(this), 1000) })
  }

  render() {
    let settings = this.props.settings;

    return (
      <Button
        onPress={() => console.log('message')}>
        <View style={styles.messageButton}>
          <Image source={require('../img/ic-start-chat.png')} />
          <Text style={[styles.messageButtonText, SHEET.buttonText]}>
            { this.state.countdown }
          </Text>
        </View>
      </Button>
    )
  }
}

class Discover extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    let candidate = this.props.candidate;
    let settings = this.props.settings;

    if (!candidate || !settings) {
      return <Text>Loading ...</Text>;
    }

    let candidateUsers = this.props.users.filter((user) => {
      return user._id == candidate.userId;
    });

    if (candidateUsers.length == 0) {
      return (<Text>Loading ...</Text>); 
    }

    let candidateUser = candidateUsers[0];
    let serviceIcons = candidateUser.connectedProfiles.map((profile) => {
      return  (<Image style={[SHEET.smallIcon, styles.serviceIcon]}
          source={{ uri: profile.icon.url }} />);
    });

    return (
      <View style={SHEET.container}>
        <ScrollView style={[SHEET.navTop, { flex: 1 }]}>
          <Card style={[{marginTop: 10, paddingBottom: 10}, SHEET.innerContainer]}
            cardOverride={{ padding: 0 }}>

            <TouchableOpacity onPress={() => {
              this.props.navigator.push({
                id: 'viewprofile',
                title: candidateUser.firstName,
                candidateUser: candidateUser,
                activities: this.state.candidateActivities
              })
            }}>
              <HeaderBanner url={candidateUser.cover.url} height={height / 2.5}>
                <View style={styles.header}>
                  <Image source={{ uri: candidateUser.avatar.url }} style={styles.avatar} />
                </View>
                <View style={styles.userInfo}>
                  <Text style={[styles.userNameText, SHEET.baseText]}>
                  { candidateUser.firstName } { candidateUser.lastName } { candidateUser.gradYear }
                </Text>
                </View>
                <View style={styles.serviceInfo}>
                  { serviceIcons }
                </View>
              </HeaderBanner>
            </TouchableOpacity>
            <View style={[styles.infoSection, SHEET.innerContainer]}>
              <IconTextRow icon={require('../img/ic-mortar.png')}
                text={candidateUser.major} />
              <IconTextRow icon={require('../img/ic-house.png')}
                text={candidateUser.hometown} />
            </View>
            <View style={[{ marginHorizontal: 10 }, SHEET.separator]} />
            <View style={[styles.infoSection, SHEET.innerContainer]}>
              <Text style={[SHEET.baseText]}>
                { candidate.reason }
              </Text>
            </View>

            <CountdownTimer settings={this.props.settings} />
          </Card>

          <View style={SHEET.bottomTile} />
        </ScrollView>
      </View>
    )
  }
}

let avatarRadius = height / 4.5;

var styles = StyleSheet.create({
  avatar: {
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
    position: 'absolute',
    backgroundColor: 'rgba(0,0,0,0)',
    bottom: 0,
    padding: 10,
  },
  serviceInfo: {
    position: 'absolute',
    backgroundColor: 'rgba(0,0,0,0)',
    flexDirection: 'row',
    bottom: 0,
    right: 0,
    padding: 10,
  },
  userNameText: {
    color: 'white',
    fontSize: 24,
  },
  infoSection: {
    paddingHorizontal: 5,
    paddingVertical: 10,
  },
  messageButton: {
    justifyContent: 'center',
    alignItems: 'center',
    flexDirection: 'row',
    marginHorizontal: 10,
    paddingVertical: 10,
    backgroundColor: COLORS.button,
    borderRadius : 3,
  },
  messageButtonText: {
    paddingLeft: 5,
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
});

module.exports = Discover;