'use strict';

let React = require('react-native');
let {
  View,
  Text,
  StyleSheet,
} = React;

let Analytics = require('../../modules/Analytics');
let COLORS = require('../CommonStyles').COLORS;
let SHEET = require('../CommonStyles').SHEET;
let Dimensions = require('Dimensions');
let { width, height } = Dimensions.get('window');

let TSConversationListView = React.requireNativeComponent('TSConversationListView', ConversationListView);

class ConversationListView extends React.Component {

  componentWillMount() {
    Analytics.track("View: Connections"); 
  }

  render() {
    // verbose but more readable IMO
    if (this.props.numTotalConversations && this.props.numTotalConversations > 0) {
      return <TSConversationListView {...this.props} />;
    }

    return (
      <View style={styles.emptyStateContainer}>
        <Text style={[styles.emptyStateText, SHEET.baseText]}>
          Your conversations will be here :)
        </Text>
      </View>
    )
  }
}

var UserSchema = React.PropTypes.shape({
    userId: React.PropTypes.string.isRequired,
    avatarUrl: React.PropTypes.string,
    coverUrl: React.PropTypes.string,
    firstName: React.PropTypes.string,
    lastName: React.PropTypes.string,
    displayName: React.PropTypes.string,
})

ConversationListView.propTypes = {
  currentUser: UserSchema,
}

var styles = StyleSheet.create({
  emptyStateContainer: {
    flex: 1,
    height: height,
    justifyContent: 'center',
    alignItems: 'center',
  },
  emptyStateText: {
    fontSize: 20,
    marginHorizontal: width / 8,
    color: COLORS.attributes,
  }
});

module.exports = ConversationListView

