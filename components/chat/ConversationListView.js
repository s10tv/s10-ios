'use strict';

let React = require('react-native');
let {
  View,
  Text,
  Image,
  StyleSheet,
} = React;

let COLORS = require('../CommonStyles').COLORS;
let SHEET = require('../CommonStyles').SHEET;
let Dimensions = require('Dimensions');
let { width, height } = Dimensions.get('window');

let TSConversationListView = React.requireNativeComponent('TSConversationListView', ConversationListView);

class ConversationListView extends React.Component {

  render() {
    // verbose but more readable IMO
    if (this.props.numTotalConversations && this.props.numTotalConversations > 0) {
      return <TSConversationListView {...this.props} />;
    }

    return (
      <View style={[SHEET.container]}>
        <View style={styles.emptyStateContainer}>
          <Image source={require('../img/message.png')} style={styles.emptyStateImage} />
          <Text style={[styles.emptyStateText, SHEET.baseText]}>
            Your conversations will be here :)
          </Text>
        </View>
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
    marginHorizontal: width / 8,
  },
  emptyStateImage: {
    width: width / 4,
    height: width / 4,
    resizeMode: 'contain',
  },
  emptyStateText: {
    paddingTop: 10,
    fontSize: 20,
    color: COLORS.attributes,
    textAlign: 'center',
  }
});

module.exports = ConversationListView

