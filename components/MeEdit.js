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
let EditMyPhotoHeader = require('./lib/EditMyPhotoHeader');
let SectionTitle = require('./SectionTitle');
let ServiceTile = require('./ServiceTile');
let ProfileEditCard = require('./lib/ProfileEditCard');
let LinkServiceCard = require('./lib/LinkServiceCard');
let AlertOnPressButton = require('./AlertOnPressButton');

class MeEdit extends React.Component {

  constructor(props: {}) {
    super(props);
    this.ddp = props.ddp;
    this.state = {
      integrations: []
    }
  }

  componentWillMount() {
    let ddp = this.ddp;
  
    Promise.all([
      ddp.subscribe({ pubName: 'integrations' }),
      ddp.subscribe({ pubName: 'me' }),
    ])
    .then(() => {
      ddp.collections.observe(() => {
        if (ddp.collections.integrations) {
          return ddp.collections.integrations.find({});
        }
      }).subscribe(results => {
        results.sort((one, two) => {
          return one.status == 'linked' ? -1 : 1;
        })
        this.setState({ integrations: results })
      })

      ddp.collections.observe(() => {
        if (ddp.collections.users) {
          return ddp.collections.users.findOne({ _id: ddp.currentUserId });
        }
      }).subscribe(currentUser => {
        this.setState({ me: currentUser })
      })
    })
  }

  render() {
    if (!this.state.me){
      return (<Text>Loading ...</Text>);
    } 

    let me = this.state.me;

    return (
      <View style={SHEET.container}>
        <ScrollView style={[SHEET.navTop]}>
          <EditMyPhotoHeader me={me} height={200} />

          <View style={SHEET.innerContainer}>
            <SectionTitle title={'SERVICES'} />
            <LinkServiceCard navigator={this.props.navigator} services={this.state.integrations} />

            <SectionTitle title={'MY INFO'} />
            <View style={SHEET.separator} />
            <ProfileEditCard me={this.state.me} ddp={this.props.ddp} />

          </View>
          <View style={SHEET.bottomTile} />
        </ScrollView>
      </View>
    )
  }
}

module.exports = MeEdit;