let React = require('react-native');
let TaylrAPI = require('react-native').NativeModules.TaylrAPI;
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

let SHEET = require('./CommonStyles').SHEET;
let COLORS = require('./CommonStyles').COLORS;
let HeaderBanner = require('./HeaderBanner');
let ContactUs = require('./ContactUs');
let Card = require('./Card').Card;
let Button = require('react-native-button');

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

class Discover extends React.Component {
  constructor(props: {}) {
    super(props);
    this.ddp = props.ddp;

    this.state = {}
  }

  componentWillUnmount() {
    if (this.state.candidateUserObserver) {
      this.state.candidateUserObserver.dispose();
    }
    if (this.state.candidateUserObserver) {
      this.state.candidateUserObserver.dispose();
    }
  }


  componentWillMount() {
    let ddp = this.ddp;

    Promise.all([
      ddp.subscribe({ pubName: 'candidate-discover'}),
      ddp.subscribe({ pubName: 'settings' })
    ])
    .then(() => {
      ddp.collections.observe(() => {
        if (ddp.collections.settings) {
          return ddp.collections.settings.findOne({ _id: 'nextMatchDate' });
        }
      }).subscribe(result => {

        // timer
        if (result) {
          let nextMatchDate = Math.floor(result.value.getTime() / 1000);
          this.setState({ nextMatchDate: nextMatchDate });

          let format = function(num) {
            return ("0" + num).slice(-2);
          }

          let timerFunction = function() {
            let now = Math.floor(new Date().getTime() / 1000);

            let interval = Math.max(nextMatchDate - now, 0)
            let hours = Math.floor(interval / 3600);
            let minutes = Math.floor((interval - hours * 3600) / 60);
            let seconds = Math.floor((interval - hours * 3600) - minutes * 60);

            this.setState({ countdown: `${format(hours)}:${format(minutes)}:${format(seconds)}`});
          }

          this.setState({ timer: setInterval(timerFunction.bind(this), 1000) })
        }
      })

      // listen for candidate publication
      let candidateObserver = ddp.collections.observe(() => {
        if (ddp.collections.candidates) {
          return ddp.collections.candidates.find({});
        }
      });

      candidateObserver.subscribe((results) => {
        if (results) {
          this.setState({ 
            candidates: results
          });

          let activeCandidates = results.filter(candidate => {
            return candidate.type == 'active' 
          });

          if (activeCandidates.length > 0) {
            let candidate = activeCandidates[0];
            this.setState({
              activeCandidate: candidate,
            });

            let activeUser = ddp.collections.users.find({ _id: candidate.userId });
            if (activeUser.length > 0) {
              this.setState({ candidateUser: activeUser[0] })
            }
          } else {
            this.setState({
              activeCandidate: undefined,
              candidateUser: undefined,
            });
          }
        }
      });

      // listen for candidate user publication as well.
      let candidateUserObserver = ddp.collections.observe(() => {
        if (ddp.collections.users && this.state.activeCandidate) {
          return ddp.collections.users.find({});
        }
      });

      candidateUserObserver.subscribe((results) => {
        if (results) {
          let activeUser = results.filter((user) => {
            return user._id == this.state.activeCandidate.userId;
          })

          if (activeUser.length > 0) {
            this.setState({ candidateUser: activeUser[0] })
          }
        }
      });

      this.setState({candidateUserObserver: candidateUserObserver});
      this.setState({candidateObserver: candidateObserver});
    })
  }

  render() {
    console.log(this.state.activeCandidate);
    if (!this.state.activeCandidate || !this.state.candidateUser || !this.state.countdown){
      return (<Text>Loading ...</Text>);
    } else {
      let candidate = this.state.activeCandidate;
      let me = this.state.candidateUser;

      let serviceIcons = me.connectedProfiles.map((profile) => {
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
                  title: me.firstName,
                  me: me
                })
              }}>
                <HeaderBanner url={me.cover.url} height={height / 2.5}>
                    <View style={styles.header}>
                      <Image source={{ uri: me.avatar.url }} style={styles.avatar} />
                    </View>
                    <View style={styles.userInfo}>
                      <Text style={[styles.userNameText, SHEET.baseText]}>
                      { me.firstName } { me.lastName } { me.gradYear }
                    </Text>
                    </View>
                    <View style={styles.serviceInfo}>
                      { serviceIcons }
                    </View>
                </HeaderBanner>
              </TouchableOpacity>
              <View style={[styles.infoSection, SHEET.innerContainer]}>
                <IconTextRow icon={require('./img/ic-mortar.png')}
                  text={me.major} />
                <IconTextRow icon={require('./img/ic-house.png')}
                  text={me.hometown} />
              </View>
              <View style={[{ marginHorizontal: 10 }, SHEET.separator]} />
              <View style={[styles.infoSection, SHEET.innerContainer]}>
                <Text style={[SHEET.baseText]}>
                  { candidate.reason }
                </Text>
              </View>

              <Button
                onPress={() => console.log('message')}>
                <View style={styles.messageButton}>
                  <Image source={require('./img/ic-start-chat.png')} />
                  <Text style={[styles.messageButtonText, SHEET.buttonText]}>
                    { this.state.countdown }
                  </Text>
                </View>
              </Button>
            </Card>

            <View style={SHEET.bottomTile} />
          </ScrollView>
        </View>
      )
    }
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