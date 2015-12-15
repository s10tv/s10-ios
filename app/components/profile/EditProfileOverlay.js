import React, {
  Dimensions,
  PickerIOS,
  View,
  DeviceEventEmitter,
  Text,
  TouchableOpacity,
  ScrollView,
  Image,
  PropTypes,
  StyleSheet,
} from 'react-native';

import { connect } from 'react-redux/native';
import Overlay from 'react-native-overlay';

import { Card } from '../lib/Card';
import FloatLabelTextField from '../lib/FloatLabelTextField';
import { SHEET, COLORS } from '../../CommonStyles';

const PickerItemIOS = PickerIOS.Item;
const { width, height } = Dimensions.get('window');
const logger = new (require('../../../modules/Logger'))('EditProfileOverlay');

function mapStateToProps(state) {
  return {
    me: state.me,
    ddp: state.ddp,
  }
}

class EditProfileOverlay extends React.Component {

  static propTypes = {
    hideModal: PropTypes.func.isRequired,
    isVisible: PropTypes.bool.isRequired,
  }

  constructor(props = {}) {
    super(props);
    this.state = {
      firstName: props.me.firstName,
      lastName: props.me.lastName,
      major: props.me.major,
      gradYear: props.me.gradYear,
      gradYearPicker: props.me.gradYear,
      hometown: props.me.hometown,
      gradYearModalVisible: false,
      about: props.me.about,
    }
  }

  renderTextField({ key, display, tapElement, multiline }) {
    return (
      <Card
        key={key}
        cardOverride={{padding: 5}}>
        <FloatLabelTextField
          ref={key}
          value={this.state[key]}
          placeHolder={display}
          tapElement={tapElement} // used by grad year only.
          ddp={this.props.ddp}
          multiline={multiline}
          onChangeText={(value) => {
            const newState = {};
            newState[key] = value;
            this.setState(newState)
          }}
        />
      </Card>
    )
  }

  renderFirstNameCell() {
    return this.renderTextField({
      key: 'firstName',
      display: 'First Name *',
      multiline: false
    })
  }

  renderLastNameCell() {
    return this.renderTextField({
      key: 'lastName',
      display: 'Last Name *',
      multiline: false
    })
  }

  renderHometownCell() {
    return this.renderTextField({
      key: 'hometown',
      display: 'Hometown *',
      multiline: false
    })
  }

  renderMajorCell() {
    return this.renderTextField({
      key: 'major',
      display: 'Major *',
      multiline: false
    })
  }

  renderGradYearCell() {
    const gradYearText = this.state.gradYear.length > 0 ?
      <Text>{ this.state.gradYear } </Text> :
      <Text style={{ color: '#B1B1B1' }}>Graduation Year *</Text>;

    const tapElement = (
      <TouchableOpacity
        key={'gradYear'}
        cardOverride={{padding: 5}}
        onPress={() => {
          this.setState({ gradYearModalVisible: true })
        }}>

        {gradYearText}
      </TouchableOpacity>
    );

    return this.renderTextField({
      key: 'gradYear',
      display: 'Graudation Year *',
      multiline: false,
      tapElement: tapElement,
    })
  }

  renderGradYearOverlay() {
    const eligibleYears = ['2009', '2010', '2011', '2012', '2013', '2014', '2015',
      '2016', '2017', '2018', '2019', '2020', '2021', '2022', '2023'];

    return (
      <Overlay isVisible={this.state.gradYearModalVisible}>
        <View style={styles.pickerBackground}>
          <View style={styles.backdrop} />
          <View style={styles.picker}>
            <PickerIOS
              selectedValue={this.state.gradYearPicker}
              onValueChange={(gradYear) => this.setState({gradYearPicker: gradYear})}>
              {eligibleYears.map((year) => (
                <PickerItemIOS
                  key={year}
                  value={year}
                  label={year} />
                )
              )}
            </PickerIOS>
            <View style={styles.pickerActions}>
              <TouchableOpacity style={styles.popupButton} onPress={() => {
                 this.setState({
                   gradYearPicker: this.state.gradYear, // reset the picker
                   gradYearModalVisible: false,
                 });
              }}>
                <Text style={styles.buttonText}>
                  Cancel
                </Text>
              </TouchableOpacity>

              <View style={styles.divider} />

              <TouchableOpacity style={styles.popupButton} onPress={() => {
                this.setState({
                  gradYear: this.state.gradYearPicker,
                  gradYearModalVisible: false,
                });
              }}>
                <Text style={styles.buttonText}>
                  Save
                </Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Overlay>
    )
  }

  renderAboutCell() {
    return this.renderTextField({
      key: 'about',
      display: 'About Me',
      multiline: true
    })
  }

  saveProfile() {
    const myInfo = {};
    myInfo.firstName = this.state.firstName;
    myInfo.lastName = this.state.lastName;
    myInfo.hometown = this.state.hometown;
    myInfo.gradYear = this.state.gradYear;
    myInfo.major = this.state.major;
    myInfo.about = this.state.about;

    return this.props.ddp.call({ methodName: 'me/update', params: [myInfo] })
    .then(() => {
      this.props.hideModal();
    })
    .catch(err => {
      this.props.dispatch({
        type: 'DISPLAY_ERROR',
        title: 'Profile Update',
        message: err.reason,
      })
    })
  }

  render() {
    return (
      <View>
        { this.renderGradYearOverlay() }
        <Overlay style={{ flex: 1}} isVisible={this.props.isVisible}>
          <View style={styles.container}>
            <View style={styles.background} />
            <ScrollView style={{height: 0.98 * height, flex: 1}}>
              <Card
                  hideSeparator={true}
                  style={[styles.card, styles.roundCorners, SHEET.innerContainer]}
                  cardOverride={styles.roundCorners}
              >

                <View style={styles.action}>
                  <TouchableOpacity style={{ flex: 1}} onPress={this.props.hideModal}>
                    <Text style={[styles.cancel, SHEET.baseText]}>
                      Cancel
                    </Text>
                  </TouchableOpacity>
                  <TouchableOpacity style={{ width: 50}} onPress={this.saveProfile.bind(this)}>
                    <Text style={[styles.save, SHEET.baseText]}>
                      Save
                    </Text>
                  </TouchableOpacity>
                </View>

                { this.renderFirstNameCell() }
                { this.renderLastNameCell() }
                { this.renderHometownCell() }
                { this.renderMajorCell() }
                { this.renderGradYearCell() }
                { this.renderAboutCell() }

              </Card>
            </ScrollView>
          </View>
        </Overlay>
      </View>
    )
  }
}

var styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  card: {
    flex: 1,
    marginTop: 0.05 * height,
  },
  roundCorners: {
    flex: 1,
    borderRadius: 5,
  },
  action: {
    flex: 1,
    paddingVertical: 10,
    flexDirection: 'row',
  },
  cancel: {
    fontSize: 16,
    color: COLORS.background,
    paddingVertical: 5,
  },
  save: {
    fontSize: 16,
    color: COLORS.taylr,
    fontWeight: 'bold',
    paddingVertical: 5,
    borderWidth: 1,
    borderColor: COLORS.taylr,
    textAlign: 'center',
  },
  background: {
    position: 'absolute',
    backgroundColor: '#000000',
    opacity: 0.5,
    height,
    width,
  },
  pickerBackground: {
    position: 'absolute',
    width: width,
    height: height,
    justifyContent: 'center',
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
  pickerActions: {
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
  popupButton: {
    flex: 1,
    height: 46,
    backgroundColor: 'white',
    alignSelf: 'stretch',
    justifyContent: 'center'
  }
})

export default connect(mapStateToProps)(EditProfileOverlay);
