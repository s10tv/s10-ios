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

  render() {
    let me = this.props.me;
    if (!me) {
      return <Text>Loading</Text>
    }

    return (
      <View style={SHEET.container}>
        <ScrollView style={[SHEET.navTop]}>
          <EditMyPhotoHeader me={me} height={200} />

          <ProfileEditCard me={me}
            style={SHEET.innerContainer}
            ddp={this.props.ddp} />

          <View style={SHEET.bottomTile} />
        </ScrollView>
      </View>
    ) 
  } 
}

module.exports = EditProfileScreen;