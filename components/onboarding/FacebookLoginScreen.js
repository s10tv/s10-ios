let React = require('react-native');

let {
  AppRegistry,
  View,
  Text,
  Image,
  TouchableOpacity,
  Navigator,
  NavigatorIOS,
  TabBarIOS,
  WebView,
  StyleSheet,
} = React;

let SHEET = require('../CommonStyles').SHEET;
let COLORS = require('../CommonStyles').COLORS;

class FacebookLoginView extends React.Component {
  render() {
    return (
      <View style={SHEET.container}>
        <View style={[SHEET.innerContainer, SHEET.navTop]}>
        </View>
      </View>
    ) 
  } 
}

module.exports = FacebookLoginView;