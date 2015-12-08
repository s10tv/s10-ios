import React, {
  View,
  PropTypes,
  ScrollView,
} from 'react-native';

import { connect } from 'react-redux/native';
import editPhotoHeader from '../lib/editPhotoHeader';
import ProfileEditCard from '../lib/ProfileEditCard';
import Loader from '../lib/Loader';
import { SHEET, COLORS } from '../../CommonStyles';

function mapStateToProps(state) {
  return {
    me: state.me,
  }
}

class CreateProfileScreen extends React.Component {

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
    let me = this.props.me;
    if (!me) {
      return <Loader />
    }

    return (
      <View style={SHEET.container}>
        <ScrollView showsVerticalScrollIndicator={false}>

          { editPhotoHeader(
              this.props.onUploadImage,
              this.props.me.avatarUrl,
              this.props.me.coverUrl)}

          <View style={SHEET.innerContainer}>
            <ProfileEditCard
              onEditProfileChange={this.props.onEditProfileChange}
              onEditProfileFocus={this.props.onEditProfileFocus}
              onEditProfileBlur={this.props.onEditProfileBlur}
              updateProfile={this.props.updateProfile}
            />
          </View>

          <View style={SHEET.bottomTile} />
        </ScrollView>
      </View>
    )
  }
}

export default connect(mapStateToProps)(CreateProfileScreen)
