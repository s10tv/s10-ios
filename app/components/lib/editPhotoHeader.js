import React, {
  Dimensions,
  View,
  Text,
  Image,
  NativeModules,
  TouchableOpacity,
  StyleSheet,
} from 'react-native';

import HeaderBanner from './HeaderBanner';
import { SHEET } from '../../CommonStyles';

const { width, height } = Dimensions.get('window');
const logger = new (require('../../../modules/Logger'))('EditPhotoHeader');

export default function editPhotoHeader(onUploadImage, avatarUrl, coverUrl) {
  return (
    <HeaderBanner url={coverUrl} height={height/3}>
      <TouchableOpacity onPress={() => { return onUploadImage({ type: 'PROFILE_PIC' }) }}>
        <View style={styles.avatarContainer}>
          <Image style={styles.avatar} source={{ uri: avatarUrl }} />
          <View style={styles.button}>
            <Text style={[styles.editText, SHEET.baseText]}>Edit Avatar</Text>
          </View>
        </View>
      </TouchableOpacity>

      <View style={[styles.buttonContainer, styles.editCoverButtonContainer]}>
        <TouchableOpacity onPress={() => { return onUploadImage({ type: 'COVER_PIC' }) }}>
          <View style={styles.button}>
            <Text style={[styles.editText, SHEET.baseText]}>Edit Cover</Text>
          </View>
        </TouchableOpacity>
      </View>
    </HeaderBanner>
  )
}

var styles = StyleSheet.create({
  avatarContainer: {
    position: 'absolute',
    backgroundColor: 'rgba(0,0,0,0)',
    left: width / 16,
    bottom: width / 16,
    width: width / 4,
  },
  avatar: {
    flex: 1,
    borderColor: 'white',
    borderWidth: 2.5,
    height: width / 4,
    borderRadius: width / 8,
  },
  editCoverButtonContainer: {
    position: 'absolute',
    right: width / 16,
    bottom: width / 16,
  },
  buttonContainer: {
    backgroundColor: 'rgba: (0,0,0,0)',
    borderWidth: 1,
    borderColor: 'white',
    alignItems: 'center',
    borderRadius: 2,
  },
  button: {
    width: width / 4,
    paddingVertical: 5,
  },
  editText: {
    flex: 1,
    color: 'white',
    textAlign: 'center',
    fontSize: 16
  },
});
