let React = require('react-native');

let {
  AppRegistry,
  View,
  Text,
  ScrollView,
  PropTypes,
  StyleSheet,
} = React;

import { connect } from 'react-redux/native';
let SHEET = require('../../CommonStyles').SHEET;
let COLORS = require('../../CommonStyles').COLORS;
let HashtagCategory = require('../lib/HashtagCategory');
let Loader = require('../lib/Loader');

function mapStateToProps(state) {
  return {
    me: state.me,
    categories: state.categories,
    myTags: state.myTags,
    ddp: state.ddp,
  }
}

class AddTagScreen extends React.Component {

  static propTypes = {
    myTags: PropTypes.object.isRequired,
    categories: PropTypes.object.isRequired,
    ddp: PropTypes.object.isRequired,
    navigator: PropTypes.object.required,
  }

  render() {
    let me = this.props.me;
    if (!me) {
      return <Loader />
    }

    return (
      <View style={SHEET.container}>
        <ScrollView
          showsVerticalScrollIndicator={false}
          style={SHEET.innerContainer}>

          <View style={styles.instructions}>
            <Text style={[styles.instructionItem, SHEET.baseText]}>
              Almost done! Tell us some final bits about yourself.
              This will help us introduce you to the most relevant
              people on campus.
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

export default connect(mapStateToProps)(AddTagScreen);
