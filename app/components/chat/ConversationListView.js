import React, {
  Text,
  StyleSheet,
} from 'react-native';

import { connect } from 'react-redux/native';
import { SCREEN_CONVERSATION_LIST } from '../../constants';

const TSConversationListView = React.requireNativeComponent(
  'TSConversationListView', ConversationListView);

function mapStateToProps(state) {
  return {
    layer: state.layer
  }
}

class ConversationListView extends React.Component {

  static id = SCREEN_CONVERSATION_LIST;

  render() {
    // verbose but more readable IMO
    if (this.props.layer.allConversationCount > 0) {
      return <TSConversationListView {...this.props} />;
    }

    return <Text>ConversationListView</Text>
  }
}

export default connect(mapStateToProps)(ConversationListView)
