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
let LinkServiceCard = require('../lib/LinkServiceCard');

class LinkServiceView extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      integrations: []
    };
  }

  componentWillMount() {
    let ddp = this.props.ddp;
    let userReqired = this.props.userReqired || true;

    ddp.subscribe({ pubName: 'integrations', userReqired: userReqired })
    .then(() => {
      ddp.collections.observe(() => {
        if (ddp.collections.integrations) {
          return ddp.collections.integrations.find({});
        }
      }).subscribe(results => {
        results.sort((one, two) => {
          return one.status == 'linked' ? -1 : 1;
        })
        this.setState({ integrations: results })
      })
    })
  }

  render() {
    if (!this.state.integrations) {
      return <Text>Loading ... </Text>
    }

    return (
      <View style={SHEET.container}>
        <View style={[SHEET.innerContainer, SHEET.navTop]}>
          <View style={styles.instructions}>
            <Text style={[styles.instructionItem, SHEET.baseText]}>
              Control how you want to appear to your classmates. 
            </Text>
            <Text style={[styles.instructionItem, SHEET.baseText]}>
              We use data from networks to tell story about you and help match you with interesting people.
            </Text>
          </View>
          <LinkServiceCard navigator={this.props.navigator} services={this.state.integrations} />
        </View>
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