let React = require('react-native');

let {
  AppRegistry,
  View,
  Text,
  ScrollView,
  StyleSheet,
} = React;

let SHEET = require('../CommonStyles').SHEET;
let COLORS = require('../CommonStyles').COLORS;
let LinkServiceCard = require('../lib/LinkServiceCard');
let Loader = require('../lib/Loader');

class LinkServiceView extends React.Component {
  render() {
    let integrations = this.props.integrations;

    if (!integrations) {
      return <Loader />
    }

    return (
      <View style={SHEET.container}>
        <ScrollView style={[SHEET.innerContainer, SHEET.navTop]}>
          <View style={styles.instructions}>
            <Text style={[styles.instructionItem, SHEET.baseText]}>
              Control how you want to appear to your classmates. 
            </Text>
            <Text style={[styles.instructionItem, SHEET.baseText]}>
              We use data from networks to tell story about you and help match 
              you with interesting people.
            </Text>
          </View>
          <LinkServiceCard navigator={this.props.navigator} services={integrations} />
        </ScrollView>
      </View>
    ) 
  } 
}

var styles = StyleSheet.create({
  instructions: {
    marginVertical: 15,
  },
  instructionItem: {
    marginVertical: 3, 
  }
});

module.exports = LinkServiceView;