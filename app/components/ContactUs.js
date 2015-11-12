let React = require('react-native');

let {
  AppRegistry,
  View,
  AlertIOS,
  Image,
  Text,
  StyleSheet,
} = React;

let Mailer = require('NativeModules').RNMail;
let SectionTitle = require('./SectionTitle');
let TappableCard = require('./Card').TappableCard;
let SHEET = require('./CommonStyles').SHEET;

class ContactUs extends React.Component {

  contactUs() {
    Mailer.mail({
      subject: 'need help',
    }, (error, event) => {
    });
  }

  render() {
    return (
      <View style={SHEET.innerContainer}>
        <SectionTitle title={'MORE'} />
        <TappableCard style={styles.card} onPress={this.contactUs}>
          <Text style={[SHEET.baseText]}>Contact Us</Text>
        </TappableCard>
        <TappableCard style={styles.card}
          onPress={() => {
            AlertIOS.alert(
              'Logout',
              'Would redirect to Native',
              [
                {text: 'Cancel', onPress: () => console.log('cancelled')},
                {text: 'Okay', onPress: () => console.log('okayed')},
              ]
            )}}>
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