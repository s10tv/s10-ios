import React, {
  AlertIOS,
  View,
  Text,
  TextInput,
  TouchableOpacity,
  ScrollView,
  StyleSheet,
  Image,
  ActivityIndicatorIOS,
  VibrationIOS,
  Dimensions,
  Animated,
} from 'react-native';

import { connect } from 'react-redux/native';
import { SHEET, COLORS} from '../../CommonStyles';
import { Card } from '../lib/Card';
import sectionTitle from '../lib/sectionTitle';
import Routes from '../../nav/Routes';
import Camera from 'react-native-camera';
const logger = new (require('../../../modules/Logger'))('EventCheckinScreen');
const { width, height } = Dimensions.get('window');

function mapStateToProps(state) {
  return {
    ddp: state.ddp,
  }
}

class EventCheckinScreen extends React.Component {

  constructor(props = {}) {
    super(props);
    this.state = {
      isJoining: false,
      barCodeFlag: false,
      showQRCodeTutorial: true,
      cameraTutorialOverlayOpacity: new Animated.Value(1.0)
    }
  }

  _onBarCodeRead(result) {
    var _this = this;

    if (this.state.barCodeFlag && result.type == Camera.constants.BarCodeType.qr) {
      this.setState({ barCodeFlag: false });
      setTimeout(() => {
        VibrationIOS.vibrate();
        _this._checkQRCode(result.data);
      }, 500);
    }
  }

  _checkQRCode(code) {
    var removeNamespaceFromCode = function(code) {
      return code.replace('events/', '');
    }
    this.setState({ isJoining: true });
    this.props.ddp.call({
      methodName: 'events/join',
      params: [removeNamespaceFromCode(code)]
    })
    .then(res => {
      const event = res;
      const route = Routes.instance.getEventDetailScreen(event);
      this.props.navigator.push(route);
      this.setState({ isJoining: false });
      var _this = this;
      setTimeout(() => {
        _this.setState({ showQRCodeTutorial: true });
      }, 400);
    })
    .catch(err => {
      logger.debug(err.message);
      this.setState({ isJoining: false });
      AlertIOS.alert('Oops.', err.reason, [{
       text: 'OK',
       onPress: () => this.setState({ barCodeFlag: true })
      }]);
    })
  }

  render() {
    var _this = this;
    // var joinButtonContents = this.state.isJoining ?
    //   <ActivityIndicatorIOS
    //     style={styles.isJoiningActivityIndicator}
    //     size='small'
    //     color='white'
    //     animating={this.state.isLoading}/> :
    //   <Text style={[SHEET.baseText, styles.joinButtonText]}>Join</Text>

    var cameraTutorialOverlay = !this.state.showQRCodeTutorial ? null :
      (
        <Animated.View style={[styles.cameraTutorialOverlay, { opacity: this.state.cameraTutorialOverlayOpacity }]}>
          <Image source={require('../img/qrcode-poster.png')} style={styles.QRCodePoster}/>
        </Animated.View>
      )

    var activityIndicator = !this.state.isJoining ? null :
      <View style={styles.activityIndicatorContainer}>
        <ActivityIndicatorIOS
          style={styles.isJoiningActivityIndicator}
          size='large'
          animating={this.state.isLoading}
          color='white'
        />
      </View>

    var fadeOutViewsAndEnableScanning = () => {
      Animated.timing(
        this.state.cameraTutorialOverlayOpacity,
        {
          toValue: 0.0,
          duration: 200,
        }
      ).start(() => this.setState({
        barCodeFlag: true,
        showQRCodeTutorial: false,
        cameraTutorialOverlayOpacity: new Animated.Value(1.0)
      }));
    }

    var gotItButton = !this.state.showQRCodeTutorial ? null :
      (
        <Animated.View style={{ opacity: this.state.cameraTutorialOverlayOpacity }}>
          <TouchableOpacity
            style={styles.gotItButton}
            onPress={fadeOutViewsAndEnableScanning.bind(this)}>
            <Text style={[SHEET.baseText, styles.gotItButtonText]}> Got it </Text>
          </TouchableOpacity>
        </Animated.View>
      )

    return (
      <View style={SHEET.container}>
        <Text style={[SHEET.baseText, styles.headerReminderText]}>
          Find the QR code at the entrance and scan it to join the event.
        </Text>
        <Camera
          ref='cam'
          style={styles.camera}
          onBarCodeRead={this._onBarCodeRead.bind(this)}
          type={Camera.constants.Type.back}
        >
          { cameraTutorialOverlay }
          { activityIndicator }
        </Camera>
        { gotItButton }
      </View>
    )
  }
}

const cameraTutorialOverlayMargin = 25
const cameraTutorialOverlayPadding = 20
var styles = StyleSheet.create({
  actions: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'flex-end',
  },
  buttonContainer: {
    flex: 1,
    marginTop: 10,
  },
  gotItButton: {
    backgroundColor: COLORS.taylr,
    padding: 10,
    marginTop: 10,
    marginHorizontal: 10,
    borderRadius: 3,
  },
  inviteCodeTextInput: {
    borderColor: COLORS.background,
    borderWidth: 1,
    padding: 10,
    height: 40,
  },
  joinEventCard: {
    borderRadius: 3,
    padding: 1
  },
  camera: {
    height: width,
    width: width,
  },
  headerReminderText: {
    marginVertical: 17,
    fontSize: 16,
    color: '#4A4A4A',
    textAlign: 'center',
    paddingHorizontal: 40,
  },
  eventPoster: {
    width: 149,
    height: 208,
    marginTop: 17,
    alignSelf: 'center',
  },
  gotItButtonText: {
    textAlign: 'center',
    fontSize: 16,
    color: COLORS.white,
  },
  activityIndicatorContainer: {
    flex: 1,
    backgroundColor: 'black',
    opacity: 0.6,
    justifyContent: 'center'
  },
  isJoiningActivityIndicator: {
    alignSelf: 'center'
  },
  cameraTutorialOverlay: {
    flex: 1,
    borderRadius: 30,
    margin: cameraTutorialOverlayMargin,
    justifyContent: 'center',
    backgroundColor: 'white',
    padding: cameraTutorialOverlayPadding,
  },
  QRCodePoster: {
    flex: 1,
    width: width - 2 * cameraTutorialOverlayMargin - 2 * cameraTutorialOverlayPadding,
    resizeMode: 'contain',
  },
})

export default connect(mapStateToProps)(EventCheckinScreen);
