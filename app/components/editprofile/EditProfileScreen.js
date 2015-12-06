import React, {
  Dimensions,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from 'react-native';

import { connect } from 'react-redux/native';

import Screen from '../Screen';

import sectionTitle from '../lib/sectionTitle';
import editPhotoHeader from '../lib/editPhotoHeader';
import linkServiceCard from '../lib/linkServiceCard';
import { SCREEN_EDIT_PROFILE } from '../../constants';
import { SHEET } from '../../CommonStyles';

const { width, height } = Dimensions.get('window');
const logger = new (require('../../../modules/Logger'))('EditProfileScreen');

function mapStateToProps(state) {
  return {
    me: state.me,
    integrations: state.integrations,
  }
}

class EditProfileScreen extends Screen {

  static id = SCREEN_EDIT_PROFILE;
  static leftButton = (route, router) => Screen.generateButton('Back', router.pop.bind(router));
  static rightButton = () => null
  static title = () => Screen.generateTitleBar('Edit');

  render() {
    logger.debug(`[integrations]: render edit profile got ${this.props.integrations.length} integrations`);

    return (
      <View style={SHEET.container}>
        <ScrollView
          showsVerticalScrollIndicator={false}
          style={[SHEET.navTop]}>

          { editPhotoHeader(
            this.props.onUploadImage,
            this.props.me.avatarUrl,
            this.props.me.coverUrl)}

          <View style={SHEET.innerContainer}>
            {sectionTitle('SERVICES')}
            { linkServiceCard(
                this.props.integrations,
                this.props.onLinkFacebook,
                this.props.onLinkViaWebView) }

            {sectionTitle('MY INFO')}
            <View style={SHEET.separator} />

          </View>
          <View style={ SHEET.bottomTile } />
        </ScrollView>
      </View>
    )
  }
}

export default connect(mapStateToProps)(EditProfileScreen)
