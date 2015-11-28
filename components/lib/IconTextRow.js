let React = require('react-native');

let {
  AppRegistry,
  View,
  Text,
  Image,
  StyleSheet,
} = React;

let SHEET = require('../CommonStyles').SHEET;

class IconTextRow extends React.Component {
  render() {
    return (
      <View style={[iconTextRowStyles.row, this.props.style]}>
        <Image source={this.props.icon} />
        <Text style={[iconTextRowStyles.text, SHEET.baseText]}>{this.props.text}</Text>
      </View>
    )
  }
}

var iconTextRowStyles = StyleSheet.create({
  row: {
    flexDirection: 'row',
  },
  text: {
    marginLeft: 10, 
  }
});

module.exports = IconTextRow;