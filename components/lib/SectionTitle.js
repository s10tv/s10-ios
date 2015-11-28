let React = require('react-native');

let {
  AppRegistry,
  View,
  Text,
  StyleSheet,
} = React;

let SHEET = require('../CommonStyles').SHEET;

class SectionTitle extends React.Component {
  render() {
    return (
      <View style={[styles.titleView, this.props.style]}>
        <Text style={[styles.title, SHEET.baseText]}>
          { this.props.title }
        </Text>
      </View>
    )
  }
}

var styles = StyleSheet.create({
  titleView: {
    paddingBottom: 4,
    paddingTop: 24,
  },
  title: {
    fontSize: 14,
    color: '#999999'
  },
});

module.exports = SectionTitle;