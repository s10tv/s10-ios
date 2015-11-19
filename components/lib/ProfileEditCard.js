let React = require('react-native');

let {
  AppRegistry,
  View,
  Text,
  TextInput,
  Image,
  StyleSheet,
} = React;

let SHEET = require('../CommonStyles').SHEET;
let TappableCard = require('./Card').TappableCard;
let Card = require('./Card').Card;

class ProfileEditCard extends React.Component {

  constructor(props) {
    super(props);

    let me = props.me;
    this.state = {
      me: me,
      firstName: me.firstName,
      lastName: me.lastName,
      major: me.major,
      about: me.about,
      hometown: me.hometown,
      gradYear: me.gradYear,
      integrations: props.integrations,
      editTimer: null,
    }
  }

  render() {
    let editInfo = [
      { key: 'firstName', display: 'First Name', multiline: false } ,
      { key: 'lastName', display: 'Last Name', multiline: false },
      { key: 'hometown', display: 'Hometown', multiline: false },
      { key: 'major', display: 'Major', multiline: false },
      { key: 'gradYear', display: 'Grad Year', multiline: false },
      { key: 'about', display: 'About Me', multiline: true },
    ];

    let editSection = editInfo.map((info) => {
      return (
        <Card>
          <Text style={[SHEET.subTitle, SHEET.baseText]}>{info.display}</Text>
          <TextInput
            style={[{ flex: 1, height: 30 }, SHEET.baseText]}
            multiline={info.multiline}
            onChangeText={(text) => {
              let newState = {};
              newState[info.key] = text;
              this.setState(newState);
             
              // don't send updates right away. Wait till they finish typing. 
              if (this.editTimer) {
                clearTimeout(this.editTimer);
              }

              this.editTimer = setTimeout(() => {
                this.props.ddp.call({ methodName: 'me/update', params: [newState] })
                .then(() => {})
                .catch(err => {
                  console.trace(err)
                });
              }, 1000)
            }}
            value={this.state[info.key]} />
        </Card>
      )
    })

    return(
      <View style={[styles.cards, this.props.style]}>
        {{ editSection }} 
      </View>
    )
  }
}

var styles = StyleSheet.create({
  cards: {
    marginVertical: 5,
  },
});

module.exports = ProfileEditCard;