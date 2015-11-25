let React = require('react-native');

let {
  AppRegistry,
  View,
  Image,
  Text,
  TouchableOpacity,
  ScrollView,
  StyleSheet,
} = React;

let Dimensions = require('Dimensions');
let { width, height } = Dimensions.get('window');

let Button = require('react-native-button')
let SHEET = require('../CommonStyles').SHEET;
let COLORS = require('../CommonStyles').COLORS;
let ProfileEditCard = require('../lib/ProfileEditCard');
let EditMyPhotoHeader = require('../lib/EditMyPhotoHeader');
let Loader = require('../lib/Loader');

class JoinNetworkScreen extends React.Component {

  render() {
    return (
      <View style={SHEET.container}>
        <View style={[SHEET.navTop]}>
          <Image source={require('../img/bg-sauder.jpg')} style={styles.bgimage} />
        </View>

        <View style={styles.contentContainer}>
          <Text style={[styles.contentText, SHEET.baseText]}>
            Taylr is currently only available to students at UBC.
          </Text>

          <TouchableOpacity
            style={styles.button}
            onPress={() => {
            this.props.navigator.push({
              id: 'campuswidelogin'
            })
          }}>
            <Image source={require('../img/ic-lock.png')} style={{ height: 15, resizeMode: 'contain' }} />
            <Text style={[styles.buttonText, SHEET.baseText]}>Campus Wide Login</Text>
          </TouchableOpacity>
        </View>
        <Text style={[styles.footerText, SHEET.baseText]}>
          We never handle or store your CWL password. You authenticate directly with CWL 
          to verify your association with UBC and populate your profile.
        </Text>
      </View>
    ) 
  } 
}

var styles = StyleSheet.create({
  bgimage: {
    width: width,
    height: height,
  },
  contentContainer: {
    position: 'absolute',
    top: height / 3,
    backgroundColor: 'transparent',
    width: 7 * width / 8,
    left: width / 16,
  },
  contentText: {
    fontSize: 22,
    color: 'white',
    textAlign: 'center',
    marginBottom: height / 16,
  },
  button: {
    backgroundColor: 'white',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    height: height / 16,
  },
  buttonText: {
    marginLeft: 5,
    fontSize: 18,
    color: 'black',
  },
  footerText: {
    position: 'absolute',
    bottom: height / 32,
    fontSize: 12,
    color: '#BDBDBD',
    width: 7 * width / 8,
    left: width / 16,
    backgroundColor: 'transparent',
  }
});

module.exports = JoinNetworkScreen;