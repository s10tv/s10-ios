import React, {
  Dimensions,
  PickerIOS,
  View,
  DeviceEventEmitter,
  Text,
  TouchableOpacity,
  Image,
  StyleSheet
} from 'react-native';

import { connect } from 'react-redux/native';
import Overlay from 'react-native-overlay'; // TODO(qimingfang): refactor into common component.

import Loader from './Loader';
import { Card, TappableCard } from './Card';
import FloatLabelTextField from './FloatLabelTextField';
import { SHEET }  from '../../CommonStyles';

const logger = new (require('../../../modules/Logger'))('ProfileEditCard');
const PickerItemIOS = PickerIOS.Item;
const { width, height } = Dimensions.get('window');

function mapStateToProps(state) {
  return {
    me: state.me,
    ddp: state.ddp,
  }
}

class ProfileEditCard extends React.Component {

  constructor(props = {}) {
    super(props);
    this.state = {
      paddingBottom: 0,
      modalVisible: false,
      gradYear: props.me.gradYear,
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
    this.setState({
      keyboardShowListener: DeviceEventEmitter.addListener('keyboardWillShow',
        this.keyboardWillShow.bind(this)),

      keyboardHideListener: DeviceEventEmitter.addListener('keyboardWillHide',
        this.keyboardWillHide.bind(this)),
    })
  }

  componentWillUnmount() {
    this.state.keyboardShowListener.remove();
    this.state.keyboardHideListener.remove();
  }

  renderTextField(info) {
    logger.debug(`rendering ${this.props.me[info.key]}`)

    return (
      <Card
        key={info.key}
        cardOverride={{padding: 5}}>
        <FloatLabelTextField
          ref={info.key}
          value={this.props.me[info.key]}
          placeHolder={info.display}
          tapElement={info.tapElement}
          isVisible={info.isVisible}
          ddp={this.props.ddp}
          multiline={info.multiline}
          onChangeText={(text) => {
            this.props.onEditProfileChange(text);
          }}
          onFocus={() => {
            this.props.onEditProfileFocus(info.key);
          }}
          onBlur={(text) => {
            this.props.onEditProfileBlur();
            this.props.updateProfile(info.key, text);
          }} />
      </Card>
    )
  }

  render() {
    // TODO(qimingfang): We shouldnt need to wait for all data to be around. The logic for
    // handling what to do when there is no data should be pushed to the Floating text label.
    // We have to wait for all data to be here first otherwise our FloatingTextFields wont
    // be re-rendered with the correct data (they have to maintain text state themselves to
    // show when users type into the text input). For now add in this hack to add spinner.
    const { firstName } = this.props.me
    if (firstName.length == 0) {
      return <Loader />
    }
    // </hack>

    let editInfo = [
      { key: 'firstName', display: 'First Name *', multiline: false } ,
      { key: 'lastName', display: 'Last Name *', multiline: false },
      { key: 'hometown', display: 'Hometown *', multiline: false },
      { key: 'major', display: 'Major *', multiline: false },
    ];

    let textFields = editInfo.map((info) => {
      return this.renderTextField.bind(this)(info)
    });

    let eligibeYears = ['2009', '2010', '2011', '2012', '2013', '2014', '2015',
    '2016', '2017', '2018', '2019', '2020', '2021', '2022', '2023'];

    let gradYearText = this.props.me.gradYear.length > 0 ?
      <Text>{ this.props.me.gradYear } </Text> :
      <Text style={{ color: '#B1B1B1' }}>Graduation Year *</Text>;

    let tapElement = (
      <TouchableOpacity
        key={'gradYear'}
        cardOverride={{padding: 5}}
        onPress={() => {
          this.setState({ modalVisible: true })
        }}>

        {gradYearText}
      </TouchableOpacity>
    );

    let gradYearField = this.renderTextField.bind(this)({
      key: 'gradYear',
      display: 'Graduation Year',
      tapElement: tapElement,
      isVisible: true,
    })

    let aboutField = this.renderTextField.bind(this)({
      key: 'about',
      display: 'About Me',
      multiline: true
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

export default connect(mapStateToProps)(ProfileEditCard);
