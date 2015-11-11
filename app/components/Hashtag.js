let React = require('react-native');

let {
  AppRegistry,
  Text,
  View,
  StyleSheet,
} = React;

let Button = require('react-native-button');
let COLORS = require('./CommonStyles').COLORS;
let SHEET = require('./CommonStyles').SHEET;
let ddp = require('../lib/ddp');

class Hashtag extends React.Component {

  _onHashtagTouch(hashtag) {
    if (!hashtag.isMine) {
      return ddp.call('me/hashtag/add', [hashtag.text, hashtag.type])
    } else {
      return ddp.call('me/hashtag/remove', [hashtag.text, hashtag.type])
    }
  }

  render() {
    let hashtag = this.props.hashtag;
    let hashtagColor = hashtag.isMine ? COLORS.taylr : COLORS.emptyHashtag;

    let hashtagButton = (
      <View 
        style={[styles.hashtag, { backgroundColor : hashtagColor }]}>
        <Text style={[styles.hashtagText, SHEET.baseText]}>{hashtag.text}</Text>
      </View>
    );

    return this.props.enableTouch ? (
        <Button onPress={() => this._onHashtagTouch.bind(this)(hashtag)}>
          { hashtagButton }                  
        </Button>
    ) : hashtagButton;
  }
}

var styles = StyleSheet.create({
  hashtag: {
    padding: 12,
    margin: 8,
  },
  hashtagText: {
    color: COLORS.white,
  }
});

module.exports = Hashtag;