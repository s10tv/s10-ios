let React = require('react-native');
let TaylrAPI = require('react-native').NativeModules.TaylrAPI;

let {
  AppRegistry,
  View,
  ScrollView,
  Text,
  TextInput,
  Image,
  Navigator,
  TouchableHighlight,
  StyleSheet,
  AlertIOS,
} = React;

let SHEET = require('./CommonStyles').SHEET;
let TappableCard = require('./Card').TappableCard;
let Card = require('./Card').Card;
let SectionTitle = require('./SectionTitle');
let ServiceTile = require('./ServiceTile');
let AlertOnPressButton = require('./AlertOnPressButton');

class MeEdit extends React.Component {

  constructor(props: {}) {
    super(props);
    this.state = {
      integrations: [],
      editTimer: null
    }
  }
  componentWillMount() {
    ddp.subscribe('me')
    .then((res) => {
      let meObserver = ddp.collections.observe(() => {
        if (ddp.collections.users) {
          return ddp.collections.users.find({ _id: this.props.userId });
        }
      });

      meObserver.subscribe((results) => {
        if (results.length == 1) {
          let me = results[0]
          this.setState({ 
            me: me,
            firstName: me.firstName,
            lastName: me.lastName,
            major: me.major,
            about: me.about,
            hometown: me.hometown,
            gradYear: me.gradYear
          });
        }
      });
    })
    .then(() => {
      return ddp.subscribe('integrations');
    })
    .then((res) => {
      let meObserver = ddp.collections.observe(() => {
        if (ddp.collections.integrations) {
          return ddp.collections.integrations.find({});
        }
      });

      meObserver.subscribe((results) => {

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
    if (!this.state.me){
      return (<Text>Loading ...</Text>);
    } 

    let me = this.state.me;

    let services = this.state.integrations.map((service) => {
      return <ServiceTile navigator={this.props.navigator} service={service} />
    });

    let editInfo = [
      { key: 'firstName', display: 'First Name', multiline: false } ,
      { key: 'lastName', display: 'Last Name', multiline: false },
      { key: 'hometown', display: 'Hometown', multiline: false },
      { key: 'major', display: 'Major', multiline: false },
      { key: 'gradYear', display: 'Grad Year', multiline: false },
      { key: 'about', display: 'About Me', multiline: true },
    ];

    let editSection = editInfo.map((info) => {
      return (
        <Card>
          <Text style={[SHEET.subTitle, SHEET.baseText]}>{info.display}</Text>
          <TextInput
            style={[{ flex: 1, height: 30 }, SHEET.baseText]}
            multiline={info.multiline}
            onChangeText={(text) => {
              let newState = {};
              newState[info.key] = text;
              this.setState(newState);
             
              // don't send updates right away. Wait till they finish typing. 
              if (this.editTimer) {
                clearTimeout(this.editTimer);
              }

              this.editTimer = setTimeout(() => {
                ddp.call('me/update', [newState])
                .then(() => {})
                .catch(err => {
                  console.trace(err)
                });
              }, 1000)
            }}
            value={this.state[info.key]} />
        </Card>
      )
    })

    return (
      <View style={SHEET.container}>
        <ScrollView style={[SHEET.navTop]}>
          <View>
            <Image style={styles.cover} source={{ uri: me.cover.url }}>
              <View style={styles.coverShadow}></View>
            </Image>
            <AlertOnPressButton title={"Update avatar"} content={"Not ready yet"}>
              <View style={styles.avatarContainer}>
                <Image style={styles.avatar} source={{ uri: me.avatar.url }} />
                <Text style={[styles.editText, SHEET.baseText]}>Edit Avatar</Text>
              </View>
            </AlertOnPressButton>

            <AlertOnPressButton title={"Update cover"} content={"Not ready yet"}>
              <View style={styles.editCoverButtonContainer}>
                <View style={styles.editCoverButton}>
                  <Text style={[styles.editText, SHEET.baseText]}>Edit Cover</Text>
                </View>
              </View>
            </AlertOnPressButton>
          </View>

          <View style={SHEET.innerContainer}>
            <SectionTitle title={'SERVICES'} />
            {{ services }} 

            <SectionTitle title={'MY INFO'} />
            <View style={styles.separator} />
            {editSection}

          </View>
          <View style={SHEET.bottomTile} />
        </ScrollView>
      </View>
    )
  }
}

var COVER_HEIGHT = 170;

var styles = StyleSheet.create({
  avatarContainer: {
    position: 'absolute',
    backgroundColor: 'rgba(0,0,0,0)', 
    left: 25,
    bottom: 20,
    width: 115,
  },
  avatar: {
    flex: 1,
    height: 115,
    borderRadius: 57.5,
  },
  editCoverButtonContainer: {
    position: 'absolute',
    right: 15,
    bottom: 20,
  },
  editCoverButton: {
    borderColor: 'white',
    borderWidth: 1,
    padding: 10,
  },
  editText: {
    flex: 1,
    color: 'white',
    textAlign: 'center',
    fontSize: 16
  },
  cover: {
    height: COVER_HEIGHT,
  },
  coverShadow: {
    height: COVER_HEIGHT,
    backgroundColor: 'black',
    opacity: 0.5
  },
  titleView: {
    paddingVertical: 15,
  },
  title: {
    fontSize: 16,
    color: '#999999'
  },
});

module.exports = MeEdit;