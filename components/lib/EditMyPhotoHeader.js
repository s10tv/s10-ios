let React = require('react-native');
let TaylrAPI = require('react-native').NativeModules.TaylrAPI;

let {
  AppRegistry,
  View,
  Text,
  Image,
  StyleSheet,
} = React;

let SHEET = require('../CommonStyles').SHEET;
let AlertOnPressButton = require('../AlertOnPressButton');

class EditMyPhotoHeader {

  render() {
    let me = this.props.me;

    return ( 
      <View>
        <Image style={{ height: this.props.height }} source={{ uri: me.cover.url }}>
          <View style={[{ height: this.props.height }, styles.coverShadow]}></View>
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
    )
  }
}

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
  coverShadow: {
    backgroundColor: 'black',
    opacity: 0.5
  }
});

module.exports = EditMyPhotoHeader;