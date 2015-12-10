let React = require('react-native');

let {
  Dimensions,
  AppRegistry,
  ActivityIndicatorIOS,
  Image,
  View,
  TouchableOpacity,
  Text,
  StyleSheet,
} = React;

import { SHEET } from '../../CommonStyles';

let Overlay = require('react-native-overlay');
let { width } = Dimensions.get('window')

class NetworkStatusOverlay extends React.Component {
  render() {
    return (
      <Overlay isVisible={this.props.isVisible}>
        <View style={styles.container}>
          <View style={[{ flex: 1}, styles.containerSubview]}>
            <ActivityIndicatorIOS animating={true} size="small"  />
            <Text style={[styles.overlayText, SHEET.baseText]}>Connecting to Network</Text>
          </View>
          <View style={[{ width: 25}, styles.containerSubview]}>
            <TouchableOpacity onPress={this.props.closePopup}>
              <Image source={ require('../img/close.png')} />
            </TouchableOpacity>
          </View>
        </View>
      </Overlay>
    )
  }
}

var styles = StyleSheet.create({
  container: {
    flex: 1,
    top: 27,
    width: width,
    paddingHorizontal: 0.05 * width,
    height: 30,

    justifyContent: 'center',
    backgroundColor: '#64369C',
    position: 'absolute',
    flexDirection: 'row',
  },
  containerSubview: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center'
  },
  overlayText: {
    marginLeft: 10,
    color: 'white',
  }
})

module.exports = NetworkStatusOverlay;
