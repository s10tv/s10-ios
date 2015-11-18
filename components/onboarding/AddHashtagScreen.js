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
let HashtagCategory = require('../lib/HashtagCategory');
let Loader = require('../lib/Loader');

class AddHashtagScreen extends React.Component {

  render() {
    let me = this.props.me;
    if (!me) {
      return <Loader />
    }

    return (
      <View style={SHEET.container}>
        <ScrollView
          showsVerticalScrollIndicator={false}
          style={[SHEET.innerContainer, SHEET.navTop]}>
          
          <View style={styles.instructions}>
            <Text style={[styles.instructionItem, SHEET.baseText]}>
              Tell us a bit more about yourself, so we can find the
              best introductions for you. 
            </Text>
          </View>

          <HashtagCategory
            categories={this.props.categories}
            myTags={this.props.myTags}
            ddp={this.props.ddp}
            navigator={this.props.navigator} />

          <View style={SHEET.bottomTile} />
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

module.exports = AddHashtagScreen;