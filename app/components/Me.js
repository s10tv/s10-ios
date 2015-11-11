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
let Button = require('react-native-button');

class Me extends React.Component {

  constructor(props: {}) {
    super(props);
    this.state = {
      modalVisible: false
    }
  }

  componentWillMount() {
    ddp.initialize().then((res) => {
      TaylrAPI.getMeteorUser((userId, resumeToken) => {
        if (resumeToken != null) {
          ddp.loginWithToken(resumeToken).then((res) => {
            ddp.subscribe('me')
            .then((res) => {
              let meObserver = ddp.collections.observe(() => {
                if (ddp.collections.users) {
                  return ddp.collections.users.find({ _id: userId });
                }
              });
              meObserver.subscribe((results) => {
                if (results.length == 1) {
                  this.setState({ me: results[0] });
                }
              });
            })
          });
        }
      });
    });
  }

  render() {
    if (!this.state.me){
      return (<Text>Loading ...</Text>);
    } else {
      let me = this.state.me;

      return (
        <View style={SHEET.container}>
          <ScrollView style={[SHEET.navTop, SHEET.bottomTile, { flex: 1 }]}>
            <Image style={styles.cover} source={{ uri: me.cover.url }}>
              <View style={styles.coverShadow}></View>
            </Image>
            <Image style={styles.avatar} source={{ uri: me.avatar.url }} />
            <View style={styles.headerView}>
              <Text style={[styles.headerName, styles.headerText, SHEET.baseText]}>{ me.firstName } { me.lastName }</Text> 
            </View>

            <View style={[styles.viewButton, styles.buttonContainer]}>
              <Button
                onPress={(event) => {}}>
                  <View style={styles.button}>
                    <Text style={[styles.buttonText, SHEET.baseText]}>View</Text>
                  </View>
              </Button>
            </View>

            <View style={[styles.editButton, styles.buttonContainer]}>
              <Button
                onPress={(event) => this.props.navigator.push({
                  id: 'editprofile',
                  title: 'Edit Profile',
                  userId: me._id
                })}>
                  <View style={styles.button}>
                    <Text style={[styles.buttonText, SHEET.baseText]}>Edit</Text>
                  </View>
              </Button>
            </View>

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
    position: 'absolute',
    left: 15,
    top: 15,
    borderRadius: 52.5,
    height: 105,
    width: 105,
  },
  cover: {
    height: 130,
  },
  coverShadow: {
    height: 130,
    backgroundColor: 'black',
    opacity: 0.5
  },
  headerView: {
    position: 'absolute',
    backgroundColor: 'rgba(0,0,0,0)',
    top: 25,
    left: 135,
  },
  headerText: {
    color: 'white',
  },
  headerName: {
    fontSize: 24
  },
  buttonContainer: {
    position: 'absolute',
    backgroundColor: 'black',
    opacity: 0.6,
    borderWidth: 1,
    borderColor: 'white',
    alignItems: 'center',
  },
  viewButton: {
    top: 75,
    left: 135,
  },
  editButton: {
    top: 75,
    left: 250,
  },
  button: {
    width: 100,
  },
  buttonText: {
    flex: 1,
    fontSize:16,
    color:'white',
    textAlign: 'center',
  }
});

module.exports = Me;