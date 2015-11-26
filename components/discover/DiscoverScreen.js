let React = require('react-native');
let Button = require('react-native-button');

let {
  AppRegistry,
  Animated,
  View,
  ScrollView,
  Text,
  Image,
  PanResponder,
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

class Discover extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      pan: new Animated.ValueXY()
    };
  }

  componentWillMount() {
    Analytics.track("View: Today"); 
    this._animatedValueY = 0; 

    this.state.pan.y.addListener((value) => {
      this._animatedValueY = value.value
    });

    this._panResponder = PanResponder.create({
      onMoveShouldSetResponderCapture: () => true, //Tell iOS that we are allowing the movement
      onMoveShouldSetPanResponderCapture: () => true, // Same here, tell iOS that we allow dragging
      onPanResponderGrant: (e, gestureState) => {
        this.state.pan.setOffset({x: 0, y: this._animatedValueY});
        this.state.pan.setValue({x: 0, y: 0}); //Initial value
      },
      onPanResponderMove: Animated.event([
        null, {dx: this.state.pan.x, dy: this.state.pan.y}
      ]), // Creates a function to handle the movement and set offsets
      onPanResponderRelease: () => {
        Animated.spring(this.state.pan, {
          toValue: 0,
          tension: 15,
        }).start();
      }
    });
  }

  componentWillUnmount() {
    this.state.pan.x.removeAllListeners();  
    this.state.pan.y.removeAllListeners();
  }

  getStyle() {
    return [
      {flex: 1, paddingTop: 74}, 
      { transform: [
        { translateY: this.state.pan.y },
      ]},
      {
        opacity: this.state.pan.x.interpolate({
          inputRange: [-200, 0, 200],
          outputRange: [0.5, 1, 0.5]})
      }
    ];
  }

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
        <Animated.View style={this.getStyle()} {...this._panResponder.panHandlers}>
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
        </Animated.View>
      </View>
    )
  }
}

let avatarRadius = height / 4.5;

var styles = StyleSheet.create({
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
    paddingHorizontal: 10,
    paddingVertical: 5,
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
    height: 40,
    justifyContent: 'center',
    alignItems: 'center',
    flexDirection: 'row',
    marginHorizontal: 10,
    backgroundColor: COLORS.button,
    marginBottom: 10,
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