let React = require('react-native');
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

  _handleServiceTouch(link) {
    this.props.navigator.push({
      id: 'servicelink',
      title: "Link Service",
      link: link
    })
  }

  render() {
    if (!this.state.me){
      return (<Text>Loading ...</Text>);
    } 

    let me = this.state.me;

    let services = this.state.integrations.map((service) => {
      let icon = service.status == 'linked' ?
        <Image style={[styles.serviceStatusIcon]} source={require('./img/ic-checkmark.png')} /> :
        <Image style={[styles.serviceStatusIcon]} source={require('./img/ic-add.png')} />

      let display = service.status == 'linked' ?
        (<View style={styles.serviceDesc}>
              <Text style={styles.serviceName}>{service.name}</Text>
              <Text style={styles.serviceId}>{service.username}</Text>
            </View>) :
        (<View style={styles.serviceDesc}>
              <Text style={styles.serviceName}>{service.name}</Text>
            </View>)

      return (
        <TouchableHighlight
          underlayColor="#ffffff"
          onPress={(event) => { return this._handleServiceTouch.bind(this)(service.url)}}>
            <View>
              <View style={styles.service}>
                <Image source={{ uri: service.icon.url }} style={[styles.serviceIcon]} />
                {display}
                {icon}
              </View>
              <View style={styles.separator} />
            </View>
        </TouchableHighlight>
      )
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
      let height = info.multiline ? 60 : 30;

      return (
        <View>
          <View style={[styles.service, { height: height + 30 }]}>
            <View style={[{flex: 1}]}>
              <Text style={styles.serviceName}>{info.display} </Text>
              <TextInput
                style={{ flex: 1, height: height }}
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
                    .then(() => {
                      console.log('saved')
                    })
                    .catch(err => {
                      console.trace(err)
                    });
                  }, 1000)
                }}
                value={this.state[info.key]} />
            </View>
          </View>
          <View style={styles.separator} />  
        </View>
      )
    })

    return (
      <View style={styles.container}>
        <ScrollView>
          <View>
            <Image style={styles.cover} source={{ uri: me.cover.url }}>
              <View style={styles.coverShadow}></View>
            </Image>
            <TouchableHighlight style={styles.avatarContainer} onPress={() => {
              AlertIOS.alert(
                'Update Avatar',
                'Is Not Supported Yet',
                [
                  {text: 'Cancel', onPress: () => console.log('Foo Pressed!')},
                  {text: 'Okay', onPress: () => console.log('Bar Pressed!')},
                ]
              )
            }}>
              <View>
                <Image style={styles.avatar} source={{ uri: me.avatar.url }} />
                <Text style={styles.editProfile}>Edit Avatar</Text>
              </View>
            </TouchableHighlight>


            <TouchableHighlight style={styles.editCoverButtonContainer} onPress={() => {
              AlertIOS.alert(
                'Update Cover',
                'Is Not Supported Yet =C',
                [
                  {text: 'Cancel', onPress: () => console.log('Foo Pressed!')},
                  {text: 'Okay', onPress: () => console.log('Bar Pressed!')},
                ]
              )
            }}>
              <View style={styles.editCoverButton}>
                <Text style={styles.editCover}>Edit Cover</Text>
              </View>
            </TouchableHighlight>
          </View>

          <View>
            <View style={styles.titleView}>
              <Text style={styles.title}>SERVICES</Text>
            </View>
            <View style={styles.separator} />
            {{ services }} 
          </View>

          <View>
            <View style={styles.titleView}>
              <Text style={styles.title}>MY INFO</Text>
            </View>
            <View style={styles.separator} />
            {editSection}
          </View>
          <View style={styles.padding} />
        </ScrollView>
      </View>
    )
  }
}

var COVER_HEIGHT = 170;

var styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingTop: 64,
    backgroundColor: '#e0e0e0'
  },
  padding: {
    height: 64
  },
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
  editProfile: {
    flex: 1,
    top: 7,
    color: 'white',
    textAlign: 'center',
    fontSize: 16
  },
  editCover: {
    flex: 1,
    color: 'white',
    textAlign: 'center',
  },
  cover: {
    height: COVER_HEIGHT,
  },
  coverShadow: {
    height: COVER_HEIGHT,
    backgroundColor: 'black',
    opacity: 0.5
  },
  headerView: {
    position: 'absolute',
    top: 25,
    left: 135,
  },
  headerText: {
    color: 'white'
  },
  headerName: {
    fontSize: 24
  },
  titleView: {
    paddingVertical: 15,
    marginHorizontal: 25,
  },
  title: {
    fontSize: 16,
    color: '#999999'
  },
  service: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    marginHorizontal: 10,
    paddingHorizontal: 25,
    height: 60,
    backgroundColor: 'white',
  },
  serviceIcon: {
    width: 32,
    height: 32,
  },
  serviceDesc: {
    flex: 1,
    margin: 10,
    left: 10,
  },
  serviceName: {
    color: '#666666',
    fontSize: 14
  },
  serviceStatusIcon: {
    width: 32,
    height: 32,
  },
  serviceId: {
    color: '#000000',
    fontSize: 15, 
  },
  separator: {
    marginHorizontal: 10,
    backgroundColor: "#e0e0e0",
    height: 1
  },
});

module.exports = MeEdit;