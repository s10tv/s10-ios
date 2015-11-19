let React = require('react-native');

let {
  AppRegistry,
  View,
  AlertIOS,
  Text,
  StyleSheet,
} = React;

let Mailer = require('NativeModules').RNMail;
let SectionTitle = require('../lib/SectionTitle');
let TappableCard = require('../lib/Card').TappableCard;
let SHEET = require('../CommonStyles').SHEET;

class ContactUs extends React.Component {

  contactUs() {
    Mailer.mail({
      subject: 'need help',
    }, (error, event) => {
    });
  }

  render() {
    return (
      <View>
        <TappableCard style={styles.card} onPress={this.contactUs}>
          <Text style={[SHEET.baseText]}>Contact Us</Text>
        </TappableCard>
        <TappableCard style={styles.card}
          onPress={() => { this.props.ddp.logout().then(() => { this.props.onLogout()}) }}>
          <Text style={[SHEET.baseText]}>Logout</Text>
        </TappableCard>
      </View>
    )
  }
}

var styles = StyleSheet.create({
  card: {
    flex: 1,
  }
});

module.exports = ContactUs;