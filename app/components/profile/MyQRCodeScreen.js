import React, {
  View,
  Image,
  Text,
  AlertIOS,
  ActivityIndicatorIOS,
  StyleSheet,
  TouchableOpacity,
  CameraRoll,
} from 'react-native';

import QRCode from 'react-native-qrcode';
import { connect } from 'react-redux/native';
import { SHEET, COLORS } from '../../CommonStyles';
const logger = new (require('../../../modules/Logger'))('MyQRCodeScreen');

function mapStateToProps(state) {
  return {
    me: state.me,
  }
}

class MyQRCodeScreen extends React.Component {
  render() {
    return (
      <View style={SHEET.container}>
        <Text style={[SHEET.baseText, styles.headerText]}>
          Let others scan this QR code to find you on Taylr!
        </Text>
        <View style={styles.QRCode}>
          <QRCode
            style={styles.QRCode}
            value={`userId/${this.props.me.userId}`}
            size={250}
            bgColor='#4A4A4A'
            fgColor={COLORS.background}
          />
          <TouchableOpacity
            style={styles.saveToCameraRollButton}
            onPress={() => {
              // CameraRoll.saveImageWithTag(, (data) => {
              //   logger.debug(data);
              // }, (err) => {
              //   logger.debug(err);
              // });
            }}>
            <Text style={[SHEET.baseText, styles.saveToCameraRollText]}>Save To Camera Roll</Text>
          </TouchableOpacity>
        </View>
      </View>
    )
  }
}

var styles = StyleSheet.create({
  headerText: {
    marginVertical: 17,
    fontSize: 18,
    color: '#4A4A4A',
    textAlign: 'center',
    paddingHorizontal: 40,
  },
  QRCode: {
    alignSelf: 'center',
  },
  saveToCameraRollButton: {
    marginVertical: 17,
    padding: 10,
    borderRadius: 3,
    backgroundColor: COLORS.taylr,
    justifyContent: 'center',
    alignSelf: 'center'
  },
  saveToCameraRollText: {
    color: 'white',
    fontSize: 16,
    textAlign: 'center',
  }
});

export default connect(mapStateToProps)(MyQRCodeScreen);
