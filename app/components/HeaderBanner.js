let React = require('react-native');
let {
  AppRegistry,
  View,
  ScrollView,
  Text,
  Image,
  TouchableOpacity,
  TouchableHighlight,
  ActionSheetIOS,
  Navigator,
  StyleSheet,
} = React;

let SHEET = require('./CommonStyles').SHEET;
let HashtagCategory = require('./HashtagCategory');
let Network = require('./Network')
let Button = require('react-native-button');


class HeaderBanner extends React.Component {

  render() {
    let me = this.props.me;

    return (
      <View style={[styles.cover, { height: this.props.height }]}>
        <Image style={styles.cover} source={{ uri: this.props.url }}>
          <View style={styles.coverShadow}></View>
        </Image>

        { this.props.children }
      </View>
    )
  }
}

var styles = StyleSheet.create({
  cover: {
    flex: 1,
    resizeMode: 'cover',
  },
  coverShadow: {
    flex: 1,
    backgroundColor: 'black',
    opacity: 0.5
  }
});

module.exports = HeaderBanner;
