let React = require('react-native');

let {
  AppRegistry,
  View,
  Text,
  ScrollView,
  StyleSheet,
} = React;

let SHEET = require('../CommonStyles').SHEET;
let COLORS = require('../CommonStyles').COLORS;
let ProfileEditCard = require('../lib/ProfileEditCard');
let EditMyPhotoHeader = require('../lib/EditMyPhotoHeader');

class EditProfileScreen extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  componentWillMount() {
    let ddp = this.props.ddp;

    ddp.subscribe({ pubName: 'me' })
    .then(() => {
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
    if (!this.state.me) {
      return <Text>Loading</Text>
    }

    return (
      <View style={SHEET.container}>
        <ScrollView style={[SHEET.navTop]}>
          <EditMyPhotoHeader me={this.state.me} height={200} />

          <ProfileEditCard me={this.state.me}
            style={SHEET.innerContainer}
            ddp={this.props.ddp} />

          <View style={SHEET.bottomTile} />
        </ScrollView>
      </View>
    ) 
  } 
}

module.exports = EditProfileScreen;