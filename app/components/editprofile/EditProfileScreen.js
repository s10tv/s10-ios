import React, {
  Dimensions,
  ScrollView,
  Text,
  View,
  PropTypes,
  StyleSheet,
} from 'react-native';

import { connect } from 'react-redux/native';

import Screen from '../Screen';

import sectionTitle from '../lib/sectionTitle';
import editPhotoHeader from '../lib/editPhotoHeader';
import linkServiceCard from '../lib/linkServiceCard';
import ProfileEditCard from '../lib/ProfileEditCard';
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

  static propTypes = {
    me: PropTypes.object.isRequired,
    onUploadImage: PropTypes.func.isRequired,
    onLinkFacebook: PropTypes.func.isRequired,
    onEditProfileChange: PropTypes.func.isRequired,
    onEditProfileFocus: PropTypes.func.isRequired,
    onEditProfileBlur: PropTypes.func.isRequired,
    updateProfile: PropTypes.func.isRequired,
  };

  render() {
    logger.debug(`[integrations]: render edit profile got ${this.props.integrations.length} integrations`);

    return (
      <View style={SHEET.container}>
        <ScrollView
          showsVerticalScrollIndicator={false}>

          { editPhotoHeader(
            this.props.onUploadImage,
            this.props.me.avatarUrl,
            this.props.me.coverUrl)}

          <View style={SHEET.innerContainer}>
            {sectionTitle('SERVICES')}
            { linkServiceCard(
                this.props.integrations,
                this.props.onLinkFacebook,
                this.props.navigator) }

            {sectionTitle('MY INFO')}
            <View style={SHEET.separator} />

            <ProfileEditCard
              onEditProfileChange={this.props.onEditProfileChange}
              onEditProfileFocus={this.props.onEditProfileFocus}
              onEditProfileBlur={this.props.onEditProfileBlur}
              updateProfile={this.props.updateProfile}
            />

          </View>
          <View style={ SHEET.bottomTile } />
        </ScrollView>
      </View>
    )
  }
}

export default connect(mapStateToProps)(EditProfileScreen)
