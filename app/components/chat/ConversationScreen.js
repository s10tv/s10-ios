import React, { View } from 'react-native';
import { connect } from 'react-redux/native';
import { SCREEN_CONVERSATION } from '../../constants'

// constants
const logger = new (require('../../../modules/Logger'))('ConversationScreen');

var TSConversationView = React.requireNativeComponent('TSConversationView', ConversationScreen);

function mapStateToProps(state) {
  return {
    me: state.me,
  }
}

class ConversationScreen extends React.Component {

  static id = SCREEN_CONVERSATION;
  static title = () => null;
  static leftButton = () => null;
  static rightButton = () => null;

  render() {
    return (
      <TSConversationView
        currentUser={this.props.me}
        conversationId={this.props.conversationId}
        recipientUser={this.props.recipientUser}
      />
    );
  }
}

let UserSchema = React.PropTypes.shape({
    userId: React.PropTypes.string.isRequired,
    avatarUrl: React.PropTypes.string,
    coverUrl: React.PropTypes.string,
    firstName: React.PropTypes.string,
    lastName: React.PropTypes.string,
    displayName: React.PropTypes.string,
})

ConversationScreen.propTypes = {
  currentUser: UserSchema.isRequired,
  conversationId: React.PropTypes.string,
  recipientUser: UserSchema,
}


export default connect(mapStateToProps)(ConversationScreen);
