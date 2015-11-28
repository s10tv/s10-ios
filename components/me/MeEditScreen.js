let React = require('react-native');
let TaylrAPI = require('react-native').NativeModules.TaylrAPI;

let {
  AppRegistry,
  View,
  Text,
  ScrollView,
  StyleSheet,
} = React;

let Dimensions = require('Dimensions');
let { width, height } = Dimensions.get('window');

let SHEET = require('../CommonStyles').SHEET;
let EditMyPhotoHeader = require('../lib/EditMyPhotoHeader');
let SectionTitle = require('../lib/SectionTitle');
let ProfileEditCard = require('../lib/ProfileEditCard');
let LinkServiceCard = require('../lib/LinkServiceCard');
let Loader = require('../lib/Loader');

class MeEdit extends React.Component {

  render() {
    let me = this.props.me;
    let integrations = this.props.integrations;

    if (!me || !integrations) {
      return <Loader />
    } 

    return (
      <View style={SHEET.container}>
        <ScrollView
          showsVerticalScrollIndicator={false}
          style={[SHEET.navTop]}>

          <EditMyPhotoHeader me={me} height={ height / 3 } ddp={this.props.ddp} />

          <View style={SHEET.innerContainer}>
            <SectionTitle title={'SERVICES'} />
            <LinkServiceCard 
              ddp={this.props.ddp}
              navigator={this.props.navigator}
              services={integrations} />

            <SectionTitle title={'MY INFO'} />
            <View style={SHEET.separator} />
            <ProfileEditCard 
              onEditProfileChange={this.props.onEditProfileChange}
              onEditProfileFocus={this.props.onEditProfileFocus}
              onEditProfileBlur={this.props.onEditProfileBlur}
              updateProfile={this.props.updateProfile}
              me={me}
              ddp={this.props.ddp} />

          </View>
          <View style={ SHEET.bottomTile } />
        </ScrollView>
      </View>
    )
  }
}

module.exports = MeEdit;