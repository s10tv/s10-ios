'use strict';

let React = require('react-native');
let ViewControllerManager = React.NativeModules.TSViewController;

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
    this.setState({
      routeListener: React.NativeAppEventEmitter.addListener(
        'ViewController.pushRoute',
        (properties) => {
          console.log(properties);
          if (properties.route == '$back') {
            //console.log(this.props.navigator.getCurrentRoutes());
            this.props.navigator.pop()
          }
          // switch (properties.route == )
          // this.props.navigator.push({
          //   id: 'conversation',
          //   conversationId: properties.conversationId,
          // })
        }
      )
    });
    ViewControllerManager.componentDidMount(React.findNodeHandle(this))
  }
  componentWillUnmount() {
    ViewControllerManager.componentWillUnmount(React.findNodeHandle(this))
    this.state.routeListener.remove();
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
