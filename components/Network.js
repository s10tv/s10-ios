let React = require('react-native');

let {
  AppRegistry,
  View,
  Image,
  Text,
  StyleSheet,
} = React;

let SectionTitle = require('./SectionTitle');
let Card = require('./Card').Card;
let SHEET = require('./CommonStyles').SHEET;

class Network extends React.Component {
  render() {
    return (
      <View style={SHEET.innerContainer}>
        <SectionTitle title={'MY SCHOOL'} />

        <Card cardOverride={styles.networkCard}>
          <Image source={require('./img/ic-ubc.png')} style={SHEET.icon} />
          <Text style={[styles.networkText, SHEET.baseText]}>University of British Columbia</Text>
        </Card>
      </View>
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