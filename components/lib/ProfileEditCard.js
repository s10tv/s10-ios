let React = require('react-native');

let {
  AppRegistry,
  AlertIOS,
  PickerIOS,
  View,
  DeviceEventEmitter,
  Text,
  TouchableOpacity,
  TextInput,
  Image,
  StyleSheet,
} = React;

let Dimensions = require('Dimensions');
let { width, height } = Dimensions.get('window');

var Overlay = require('react-native-overlay');

let FloatLabelTextInput = require('./FloatLabelTextField');

let SHEET = require('../CommonStyles').SHEET;
let Card = require('./Card').Card;
let TappableCard = require('./Card').TappableCard;
let Logger = require('../../lib/Logger');

let PickerItemIOS = PickerIOS.Item;

class ProfileEditCard extends React.Component {

  constructor (props) {
    super(props)
    this.state = {
      paddingBottom: 0,
      modalVisible: false,
      gradYear: props.me.gradYear,
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

  renderTextField(info) {
    return (
        <Card 
          key={info.key}
          cardOverride={{padding: 5}}>
          <FloatLabelTextInput
            ref={info.key}
            value={this.props.me[info.key]}
            placeHolder={info.display}
            tapElement={info.tapElement}
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
  }

  render() {
    let editInfo = [
      { key: 'firstName', display: 'First Name *', multiline: false } ,
      { key: 'lastName', display: 'Last Name *', multiline: false },
      { key: 'hometown', display: 'Hometown *', multiline: false },
      { key: 'major', display: 'Major *', multiline: false },
    ];

    let textFields = editInfo.map((info) => {
      return this.renderTextField.bind(this)(info)
    });

    let aboutField = this.renderTextField.bind(this)({
      key: 'about',
      display: 'About Me',
      multiline: true
    })

    let eligibeYears = ['2009', '2010', '2011', '2012', '2013', '2014', '2015',
    '2016', '2017', '2018', '2019', '2020', '2021', '2022', '2023'];

    let tapElement = (
      <TouchableOpacity
        key={'gradYear'}
        cardOverride={{padding: 5}}
        onPress={() => {
          this.setState({ modalVisible: true })
        }}>
        <Text>{ this.props.me.gradYear } </Text>
      </TouchableOpacity>
    );

    let gradYearField = this.renderTextField.bind(this)({
      key: 'gradYear',
      display: 'Graduation Year',
      tapElement: tapElement,
    })

    return(
      <View>
        <View style={[{ paddingBottom: this.state.paddingBottom }, styles.cards, this.props.style]}>
          { textFields }
          { gradYearField } 
          { aboutField }
        </View>

        <Overlay isVisible={this.state.modalVisible}>
          <View style={styles.background}>
            <View style={styles.backdrop} />
            <View style={styles.picker}>
              <PickerIOS
                selectedValue={this.state.gradYear}
                onValueChange={(gradYear) => this.setState({gradYear: gradYear})}>
                {eligibeYears.map((year) => (
                  <PickerItemIOS
                    key={year}
                    value={year}
                    label={year} />
                  )
                )}
              </PickerIOS>
              <View style={styles.actions}>
                <TouchableOpacity style={[styles.button, styles.cancelButton]} onPress={() => {
                   this.setState({ modalVisible: false });
                }}>
                  <Text style={styles.buttonText}>
                    Cancel
                  </Text>
                </TouchableOpacity>

                <View style={styles.divider} />

                <TouchableOpacity style={styles.button} onPress={() => {
                  this.props.updateProfile('gradYear', this.state.gradYear);
                  this.setState({ modalVisible: false });
                }}>
                  <Text style={styles.buttonText}>
                    Save
                  </Text>
                </TouchableOpacity>
              </View>
            </View>
          </View>
        </Overlay>
      </View>
    )
  }
}

var styles = StyleSheet.create({
  cards: {
    marginVertical: 5,
  },
  backdrop: {
    position: 'absolute',
    top: 0,
    left: 0,
    width: width,
    height: height,
    backgroundColor: 'black',
    opacity: 0.75,
  },
  picker: {
    backgroundColor: 'white',
    marginHorizontal: width / 16,
    borderColor: 'white',
    borderWidth: 1,
    padding: 6,
    borderRadius: 6,
  },
  background: {
    position: 'absolute',
    width: width,
    height: height,
    justifyContent: 'center',
  },
  actions: {
    flex: 1,
    flexDirection: 'row',
    borderTopColor: '#cccccc',
    borderTopWidth: 1,
  },
  buttonText: {
    color: '#0069d5',
    alignSelf: 'center',
    fontSize: 18
  },
  divider: {
    width: 1,
    height: 46,
    backgroundColor: '#cccccc',
  },
  button: {
    flex: 1,
    height: 46,
    backgroundColor: 'white',
    alignSelf: 'stretch',
    justifyContent: 'center'
  }
});

module.exports = ProfileEditCard;