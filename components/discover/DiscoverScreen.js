let React = require('react-native');
let Button = require('react-native-button');

let {
  AppRegistry,
  View,
  ScrollView,
  Text,
  Image,
  TouchableOpacity,
  StyleSheet,
} = React;

let Dimensions = require('Dimensions');
let { width, height } = Dimensions.get('window');

let Analytics = require('../../modules/Analytics');
let SHEET = require('../CommonStyles').SHEET;
let COLORS = require('../CommonStyles').COLORS;
let HeaderBanner = require('../lib/HeaderBanner');
let IconTextRow = require('../lib/IconTextRow');
let CountdownTimer = require('../lib/CountdownTimer');
let Card = require('../lib/Card').Card;
let Loader = require('../lib/Loader');

const logger = new (require('../../lib/Logger'))('index.ios');

class Discover extends React.Component {

  render() {
    const candidate = this.props.candidate;
    const settings = this.props.settings;

    if (!candidate || !settings) {
      return <Loader />;
    }

    const candidateUsers = this.props.users.filter((user) => {
      return user._id == candidate.userId;
    });

    if (candidateUsers.length == 0) {
      return <Loader />;
    }

    const [candidateUser] = candidateUsers;
    let { firstName, lastName, gradYear, cover, connectedProfiles,
      avatar, major, hometown, shortDisplayName } = candidateUser;

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
        <View style={styles.background}>
          <Image
            source={require('../img/bg-compass.png')}
            style={{ width: width / 1.5, height: width / 1.5, resizeMode: 'contain' }} />
          <Text style={[styles.backgroundQuoteText, SHEET.baseText]}>
            Every good friend was once a stranger.
          </Text>
        </View>
        <View style={{flex: 1, paddingTop: 74}}>
          <Card style={[{flex: 1, marginBottom: 10}, SHEET.innerContainer]}
            cardOverride={[{ flex: 1, padding: 0 }]}>
              <TouchableOpacity onPress={() => {
                Analytics.track("Today: TapProfile")
                this.props.parentNavigator.push({
                  id: 'viewprofile',
                  me: candidateUser,
                  candidateUser: candidateUser,
                  isCurrentCandidate: true,
                })
              }}>
                <HeaderBanner url={cover.url} height={height / 2.5}>
                  <View style={styles.header}>
                    <Image source={{ uri: avatar.url }} style={styles.avatar} />
                  </View>

                  <View style={styles.bottomInfo}>
                    <View style={styles.userInfo}>
                      <Text style={[styles.userNameText, SHEET.baseText]}>
                      { shortDisplayName }
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
              </TouchableOpacity>

            <View style={[styles.infoSection, SHEET.innerContainer]}>
              <IconTextRow
                style={{ padding: 5 }}
                icon={require('../img/ic-mortar.png')}
                text={major} />
              <IconTextRow
                style={{ padding: 5 }}
                icon={require('../img/ic-house.png')}
                text={hometown} />
            </View>

            <View style={[{ marginHorizontal: 10 }, SHEET.separator]} />
            
            <View style={[{ flex: 1}, styles.infoSection, SHEET.innerContainer]}>
              <Text style={[SHEET.baseText]}>
                { candidate.reason }
              </Text>
            </View>

            <CountdownTimer
              navigator={this.props.parentNavigator}
              candidateUser={candidateUser}
              me={this.props.me}
              settings={this.props.settings} />
          </Card>
        </View>
      </View>
    )
  }
}

let avatarRadius = height / 4.5;

var styles = StyleSheet.create({
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
    height: 32,
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
    paddingHorizontal: width / 64,
    paddingVertical: 10,
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
});

module.exports = Discover;