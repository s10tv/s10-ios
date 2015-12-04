import React, { View } from 'react-native';
import { connect } from 'react-redux/native';

// constants
const logger = new (require('../../../modules/Logger'))('FacebookLoginHandler');

var TSConversationView = React.requireNativeComponent('TSConversationView', ConversationScreen);

function mapStateToProps(state) {
  logger.debug(`state.routes: ${JSON.stringify(state.routes)}`);
  return {
    me: state.me,
    currentProps: state.routes.fullscreen.currentProps,
  }
}

class ConversationScreen extends React.Component {
  render() {
    return (
      <TSConversationView
        currentUser={this.props.me}
        {...this.props}
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
