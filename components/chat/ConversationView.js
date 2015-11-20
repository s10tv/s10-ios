'use strict';

let React = require('react-native');
let BridgeManager = React.NativeModules.TSBridgeManager;

let UserSchema = React.PropTypes.shape({
    userId: React.PropTypes.string.isRequired,
    avatarUrl: React.PropTypes.string,
    coverUrl: React.PropTypes.string,
    firstName: React.PropTypes.string,
    lastName: React.PropTypes.string,
    displayName: React.PropTypes.string,
})

class ConversationView extends React.Component {
  componentDidMount() {
    BridgeManager.componentDidMount(React.findNodeHandle(this))
  }
  componentWillUnmount() {
    BridgeManager.componentWillUnmount(React.findNodeHandle(this))
  }
  render() {
    return <TSConversationView {...this.props} />;
  }
}

ConversationView.propTypes = {
  currentUser: UserSchema.isRequired,
  conversationId: React.PropTypes.string,
  recipientUser: UserSchema,
}

var TSConversationView = React.requireNativeComponent('TSConversationView', ConversationView);

module.exports = ConversationView
