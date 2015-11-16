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

    let shadow = this.props.hideShadow ? null : <View style={styles.coverShadow}></View>;

    return (
      <View style={[styles.cover, { height: this.props.height }]}>
        <Image style={styles.cover} source={{ uri: this.props.url }}>
          { shadow }
        </Image>

        { this.props.children }
      </View>
    )
  }
}

var styles = StyleSheet.create({
  cover: {
    flex: 1,
  },
  coverShadow: {
    flex: 1,
    backgroundColor: 'black',
    opacity: 0.5,
  }
});

module.exports = HeaderBanner;
