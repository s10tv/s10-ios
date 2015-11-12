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

let SHEET = require('./CommonStyles').SHEET;
let HashtagCategory = require('./HashtagCategory');
let Network = require('./Network')
let HeaderBanner = require('./HeaderBanner');
let Button = require('react-native-button');

class MeButton extends React.Component {
  render() {
    return(
      <View style={[buttonStyles.container, this.props.style]}>
        <Button
          onPress={this.props.onPress}>
            <View style={buttonStyles.button}>
              <Text style={[buttonStyles.buttonText, SHEET.baseText]}>
                { this.props.text }
              </Text>
            </View>
        </Button> 
      </View>
    ) 
  }
}
var buttonStyles = StyleSheet.create({
  container: {
    backgroundColor: 'black',
    opacity: 0.6,
    borderWidth: 1,
    borderColor: 'white',
    alignItems: 'center',
    borderRadius: 2,
  },
  button: {
    width: 100,
  },
  buttonText: {
    flex: 1,
    paddingVertical: 5,
    fontSize:16,
    color:'white',
    textAlign: 'center',
  }
});

class MeHeader extends React.Component {

  constructor(props) {
    super(props);

    this.state = {
      integrations: props.me.connectedProfiles
    }
  }

  componentWillMount() {
    ddp.subscribe('integrations')
    .then(() => {
      let observer = ddp.collections.observe(() => {
        if (ddp.collections.integrations) {
          return ddp.collections.integrations.find({});
        }
      });

      observer.subscribe((results) => {
        results.sort((one, two) => {
          oneLinked = one.status == 'linked'
          twoLinked = two.status == 'linked'
          if (oneLinked === twoLinked) {
            return 0 
          } else {
            if (oneLinked) {
              return -1
            } else {
              return 1;
            }
          }
        })

        this.setState({ integrations: results });
      });
    })
  }

  render() {
    let me = this.props.me;
    let serviceIcons = this.state.integrations.map((integration) => {
      return integration.status == 'unlinked' ? null :
        (<Image style={[SHEET.smallIcon, styles.serviceIcon]}
          source={{ uri: integration.icon.url }} />);
    });

    return (
      <View style={styles.meHeader}>
        <Image style={styles.avatar} source={{ uri: me.avatar.url }} />
        <View style={styles.headerContent}>
          <Text style={[styles.headerText, SHEET.baseText]}>
            {me.firstName} {me.lastName} {me.gradYear}
          </Text>
          <View style={styles.headerContentLineItem}>
            { serviceIcons }
          </View>
          <View style={styles.headerContentLineItem}>
            <MeButton text={'View'} />
            <MeButton style={{ left:10 }} text={'Edit'} onPress={() => {
              this.props.navigator.push({
                id: 'editprofile',
                title: 'Edit Profile',
                userId: me._id,
                me: me,
                integrations: this.state.integrations
              })}} />
          </View>
        </View>
      </View>
    )
  }
}

class Me extends React.Component {
  constructor(props: {}) {
    super(props);
    this.state = {}
  }

  componentWillMount() {
    ddp.initialize().then((res) => {
      return new Promise((resolve, reject) => {
        TaylrAPI.getMeteorUser((userId, resumeToken) => {
          if (resumeToken == null) {
            return reject('Resume Token not found');
          }

          return resolve({ userId: userId, token: resumeToken });
        });
      })
    }).then(loginResult => {
      this.setState({ userId: loginResult.userId });
      return ddp.loginWithToken(loginResult.token)
    }).then((res) => {
      return ddp.subscribe('me');
    })
    .then(() => {
      let observer = ddp.collections.observe(() => {
        if (ddp.collections.users) {
          return ddp.collections.users.find({ _id: this.state.userId });
        }
      });
      observer.subscribe((results) => {
        if (results.length == 1) {
          this.setState({ me: results[0] });
        }
      });
    })
  }

  render() {
    if (!this.state.me){
      return (<Text>Loading ...</Text>);
    } else {
      let me = this.state.me;

      return (
        <View style={SHEET.container}>
          <ScrollView style={[SHEET.navTop, SHEET.bottomTile, { flex: 1 }]}>
            <HeaderBanner url={me.cover.url} height={170}>
              <MeHeader navigator={this.props.navigator} me={me} />
            </HeaderBanner>
            <Network navigator={this.props.navigator} />

            <HashtagCategory navigator={this.props.navigator} />
            <View style={SHEET.bottomTile} />
          </ScrollView>
        </View>
      )
    }
  }
}

var styles = StyleSheet.create({
  avatar: {
    borderRadius: 52.5,
    height: 105,
    width: 105,
  },
  meHeader: {
    position: 'absolute',
    backgroundColor: 'rgba(0,0,0,0)',
    top: 0,
    left: 0,
    alignItems: 'center',
    flexDirection: 'row',
    height: 170,
    marginHorizontal: 15,
  },
  headerContent: {
    flexDirection: 'column',
    left: 15,
  },
  headerContentLineItem: {
    flex: 1,
    flexDirection: 'row',
    marginTop: 10,
  },
  headerText: {
    color: 'white',
    fontSize: 24
  },
  serviceIcon: {
    marginRight: 5,
  },
});

module.exports = Me;