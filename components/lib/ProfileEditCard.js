let React = require('react-native');

let {
  AppRegistry,
  View,
  DeviceEventEmitter,
  Text,
  TextInput,
  Image,
  StyleSheet,
} = React;

let FloatLabelTextInput = require('./FloatLabelTextField');
let SHEET = require('../CommonStyles').SHEET;
let TappableCard = require('./Card').TappableCard;
let Card = require('./Card').Card;

class ProfileTextInput extends React.Component {
  constructor(props = {}) {
    super(props);
    this.state = {
      text: props.text,
    }
  }

  render() {
    return (
      <FloatLabelTextInput
          placeHolder={this.props.display}
          multiline={this.props.multiline}
          value={this.props.text}
          onBlur={() => {
            let myInfo = {};
            myInfo[this.props.infoKey] = this.state.text;
            this.props.ddp.call({ methodName: 'me/update', params: [myInfo] })
          }} />
    )
  }
}

class ProfileEditCard extends React.Component {

  constructor (props) {
    super(props)
    this.state = {
      paddingBottom: 0,
    }
  } 

  keyboardWillShow (e) {
    let newSize = e.endCoordinates.height
    this.setState({paddingBottom: newSize})
  }

  keyboardWillHide (e) {
    this.setState({paddingBottom: 0})
  }

  componentWillMount () {
    DeviceEventEmitter.addListener('keyboardWillShow', this.keyboardWillShow.bind(this))
    DeviceEventEmitter.addListener('keyboardWillHide', this.keyboardWillHide.bind(this))
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
        <Card 
          key={info.key}
          cardOverride={{padding: 5}}>
          <ProfileTextInput
            ref={info.key}
            text={this.props.me[info.key]}
            display={info.display}
            ddp={this.props.ddp}
            infoKey={info.key}
            multiline={info.multiline} />
        </Card>
      )
    })

    return(
      <View style={[{ paddingBottom: this.state.paddingBottom }, styles.cards, this.props.style]}>
        { editSection }
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