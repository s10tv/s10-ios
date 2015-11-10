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
} = React;

var userId = 'KW7Eszw5th6QSeoJv';
var token = 'vU8rq_HWmJm7LNHx78anzipsNu9XUYY26jsWvn8Bfdx';

class MeEdit extends React.Component {

  constructor(props: {}) {
    super(props);
    this.state = {
      integrations: [],
    }
  }
  componentWillMount() {
    ddp.initialize()
    .then(() => {
      return ddp.loginWithToken(token) 
    })
    .then(() => {
      return ddp.subscribe('me');
    })
    .then((res) => {
      let meObserver = ddp.collections.observe(() => {
        if (ddp.collections.users) {
          return ddp.collections.users.find({ _id: userId });
        }
      });

      meObserver.subscribe((results) => {
        if (results.length == 1) {
          let me = results[0]
          this.setState({ 
            me: me,
            firstName: me.firstName,
            lastName: me.lastName,
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
      let iconStyle = service.status == 'linked'? styles.linked : styles.unlinked;

      let icon = service.status == 'linked' ?
        <Image style={[iconStyle, styles.serviceStatusIcon]} source={{ uri: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-checkmark.png' }} /> :
        <Image style={[iconStyle, styles.serviceStatusIcon]} source={{ uri: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-warning.png' }} />

      let display = service.status == 'linked' ?
        ( <View style={styles.serviceDesc}>
              <Text style={styles.serviceName}>{service.name}</Text>
              <Text style={styles.serviceId}>{service.username}</Text>
            </View>) :
        ( <View style={styles.serviceDesc}>
              <Text style={styles.serviceName}>{service.name}</Text>
            </View>)

      return (
        <TouchableHighlight
          underlayColor="#ffffff"
          onPress={(event) => { return this._handleServiceTouch.bind(this)(service.url)}}>
            <View>
              <View style={styles.service}>
                <Image source={{ uri: service.icon.url }} style={[iconStyle, styles.serviceIcon]} />
                {display}
                {icon}
              </View>
              <View style={styles.separator} />
            </View>
        </TouchableHighlight>
      )
    });

    let editInfo = [
      { key: 'firstName', display: 'First Name' } ,
      { key: 'lastName', display: 'Last Name'},
      { key: 'hometown', display: 'Hometown'},
      { key: 'gradYear', display: 'Grad Year'},
    ];


    let editSection = editInfo.map((info) => {

      return (
        <View>
        <View style={styles.service}>
          <Text style={styles.serviceName}>{info.display} </Text>
          <TextInput
            style={{height: 20 }}
            onChangeText={(text) => {
              let newState = {};
              newState[info.key] = text;
              this.setState(newState);
            }}
            value={this.state[info.key]} />
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
            <Image style={styles.avatar} source={{ uri: me.avatar.url }} />
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

var styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingTop: 64,
    backgroundColor: '#e0e0e0'
  },
  padding: {
    height: 64
  },
  avatar: {
    position: 'absolute',
    left: 25,
    top: 25,
    borderRadius: 57.5,
    height: 115,
    width: 115,
  },
  cover: {
    height: 170,
  },
  coverShadow: {
    height: 170,
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
    marginHorizontal: 10,
    paddingHorizontal: 25,
    height: 60,
    backgroundColor: 'white',
  },
  serviceIcon: {
    position: 'absolute',
    left: 15,
    width: 32,
    height: 32,
  },
  serviceDesc: {
    margin: 10,
    left: 20,
  },
  serviceName: {
    color: '#666666',
    fontSize: 14
  },
  serviceStatusIcon: {
    position: 'absolute',
    right: 15,
    width: 32,
    height: 32,
    alignItems: 'center',
  },
  unlinked: {
    top: 10
  },
  linked: {
    top: 15
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