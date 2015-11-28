let React = require('react-native');

let {
  AppRegistry,
  AlertIOS,
  View,
  DeviceEventEmitter,
  Text,
  TextInput,
  Image,
  StyleSheet,
} = React;

let FloatLabelTextInput = require('./FloatLabelTextField');
let SHEET = require('../CommonStyles').SHEET;
let Card = require('./Card').Card;
let Logger = require('../../lib/Logger');

class ProfileEditCard extends React.Component {

  constructor (props) {
    super(props)
    this.state = {
      paddingBottom: 0,
    }
    this.logger = new Logger(this);
  } 

  keyboardWillShow (e) {
    let newSize = e.endCoordinates.height
    this.setState({paddingBottom: newSize})
  }

  keyboardWillHide (e) {
    this.setState({paddingBottom: 0})
  }

  componentWillMount () {
    this.setState({
      keyboardShowListener: DeviceEventEmitter.addListener('keyboardWillShow', this.keyboardWillShow.bind(this)),
      keyboardHideListener: DeviceEventEmitter.addListener('keyboardWillHide', this.keyboardWillHide.bind(this)),
    })
  }

  componentWillUnmount() {
    this.state.keyboardShowListener.remove();
    this.state.keyboardHideListener.remove();
  }

  render() {
    let editInfo = [
      { key: 'firstName', display: 'First Name *', multiline: false } ,
      { key: 'lastName', display: 'Last Name *', multiline: false },
      { key: 'hometown', display: 'Hometown *', multiline: false },
      { key: 'major', display: 'Major *', multiline: false },
      { key: 'gradYear', display: 'Grad Year *', multiline: false },
      { key: 'about', display: 'About Me', multiline: true },
    ];

    let editSection = editInfo.map((info) => {
      return (
        <Card 
          key={info.key}
          cardOverride={{padding: 5}}>
          <FloatLabelTextInput
            ref={info.key}
            value={this.props.me[info.key]}
            placeHolder={info.display}
            ddp={this.props.ddp}
            multiline={info.multiline}
            onChangeText={(text) => {
              if (this.props.onEditProfileChange) {
                this.props.onEditProfileChange(text);
              }
            }}
            onFocus={() => {
              if (this.props.onEditProfileFocus) {
                this.props.onEditProfileFocus(info.key);
              }
            }}
            onBlur={(text) => {
              if (this.props.onEditProfileBlur) {
                this.props.onEditProfileBlur();
              }
              this.props.updateProfile(info.key, text);
            }} />
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