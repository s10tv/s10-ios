import React, {
  Text,
  StyleSheet,
} from 'react-native';

import { connect } from 'react-redux/native';

const TSConversationListView = React.requireNativeComponent(
  'TSConversationListView', ConversationListView);

function mapStateToProps(state) {
  return {
    layer: state.layer
  }
}

class ConversationListView extends React.Component {

  render() {
    // verbose but more readable IMO
    if (this.props.layer.allConversationCount > 0) {
      return <TSConversationListView {...this.props} />;
    }

    return <Text>ConversationListView</Text>
  }
}

export default connect(mapStateToProps)(ConversationListView)
