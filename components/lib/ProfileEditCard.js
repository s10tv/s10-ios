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

let Analytics = require('../../modules/Analytics');
let FloatLabelTextInput = require('./FloatLabelTextField');
let SHEET = require('../CommonStyles').SHEET;
let Card = require('./Card').Card;
let Logger = require('../../lib/Logger');

class ProfileEditCard extends React.Component {

  constructor (props) {
    super(props)
    this.state = {
      paddingBottom: 0,
      isFocused: false,
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

  updateMeteor(key, value) {
    let myInfo = {};
    myInfo[key] = value;

    Analytics.track('EditProfile: Save', myInfo);
    this.logger.info(`Updating meteor with ${key} >> ${value}`);

    return this.props.ddp.call({ methodName: 'me/update', params: [myInfo] })
    .catch(err => {
      this.logger.error(JSON.stringify(err));
      AlertIOS.alert('Error', err.reason);
    })
  }

  componentWillMount () {
    this.setState({
      keyboardShowListener: DeviceEventEmitter.addListener('keyboardWillShow', this.keyboardWillShow.bind(this)),
      keyboardHideListener: DeviceEventEmitter.addListener('keyboardWillHide', this.keyboardWillHide.bind(this)),
    })
  }

  componentWillUnmount() {
    let { isFocused, activeKey, activeText } = this.state;
    if (isFocused && activeText && activeKey) {
      this.updateMeteor(activeKey, activeText);
    }
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
              this.setState({ activeText: text })
            }}
            onFocus={(text) => {
              this.setState({
                isFocused: true,
                activeKey: info.key,
              })
            }}
            onBlur={(text) => {
              this.setState({
                isFocused: false,
                activeKey: null,
                activeText: null,
              })
              this.updateMeteor(info.key, text);
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