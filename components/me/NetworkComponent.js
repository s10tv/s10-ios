let React = require('react-native');

let {
  AppRegistry,
  View,
  Image,
  Text,
  StyleSheet,
} = React;

let SHEET = require('../CommonStyles').SHEET;
let SectionTitle = require('../lib/SectionTitle');
let Card = require('../lib/Card').Card;

class Network extends React.Component {
  render() {
    return (
      <Card cardOverride={styles.networkCard}>
        <Image source={require('../img/ic-ubc.png')} style={SHEET.icon} />
        <Text style={[styles.networkText, SHEET.baseText]}>University of British Columbia</Text>
      </Card>
    )
  }
}

var styles = StyleSheet.create({
  networkCard: {
    flex: 1,
    alignItems: 'center',
    flexDirection: 'row',
  },
  networkText: {
    flex: 1,
    left: 8, 
  }
});

module.exports = Network;