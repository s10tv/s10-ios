'use strict';

let React = require('react-native');

let UserSchema = React.PropTypes.shape({
    userId: React.PropTypes.string.isRequired,
    avatarUrl: React.PropTypes.string,
    coverUrl: React.PropTypes.string,
    firstName: React.PropTypes.string,
    lastName: React.PropTypes.string,
    displayName: React.PropTypes.string,
})

class ConversationView extends React.Component {
  render() {
    return <TSConversationView {...this.props} />;
  }
}

ConversationView.propTypes = {
  currentUser: UserSchema,
  conversationId: React.PropTypes.string.isRequired,
}

var TSConversationView = React.requireNativeComponent('TSConversationView', ConversationView);

module.exports = ConversationView
