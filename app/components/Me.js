let React = require('react-native');
let {
  AppRegistry,
  View,
  ScrollView,
  Text,
  Image,
  TouchableOpacity,
  Navigator,
  StyleSheet,
} = React;

let HashtagCategory = require('./HashtagCategory');

var userId = 'KW7Eszw5th6QSeoJv';
var token = 'vU8rq_HWmJm7LNHx78anzipsNu9XUYY26jsWvn8Bfdx';

class Me extends React.Component {

  constructor(props: {}) {
    super(props);
    this.state = {
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
        <ScrollView style={styles.container}>

          <View>
            <Image style={styles.cover} source={{ uri: me.cover.url }}>
              <View style={styles.coverShadow}></View>
            </Image>
            <Image style={styles.avatar} source={{ uri: me.avatar.url }} />
            <View style={styles.headerView}>
              <Text style={[styles.headerName, styles.headerText]}>{ me.firstName } { me.lastName }</Text> 
            </View>

            <View style={[styles.viewButton, styles.button]}>
              <Text style={[styles.buttonText]}>View</Text>
            </View>
            <View style={[styles.editButton, styles.button]}>
              <Text style={[styles.buttonText]}>Edit</Text>
            </View>
          </View>

          <HashtagCategory navigator={this.props.navigator} />
        </ScrollView>
      )
    }
  }
}

var styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingTop: 64,
  },
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
    top: 25,
    left: 135,
  },
  headerText: {
    color: 'white'
  },
  headerName: {
    fontSize: 24
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
    position: 'absolute',
    backgroundColor: 'black',
    opacity: 0.6,
    borderWidth: 1,
    borderColor: 'white',
    width: 100,
    alignItems: 'center',
    paddingVertical: 2
  },
  buttonText: {
    fontSize:16,
    color:'white'
  }
});

module.exports = Me;