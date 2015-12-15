let React = require('react-native');

let {
  AppRegistry,
  Text,
  View,
  StyleSheet,
} = React;

let Button = require('react-native-button');
import {COLORS, SHEET} from '../../CommonStyles';

const logger = new (require('../../../modules/Logger'))('Hashtag');

class Hashtag extends React.Component {

  constructor(props) {
    super(props);
    this.ddp = props.ddp;
  }

  _onHashtagTouch(hashtag) {
    logger.info('changed hashtag');

    if (!hashtag.isMine) {
      return this.ddp.call({
        methodName: 'me/hashtag/add',
        params: [hashtag.text, hashtag.type]
      })
      .catch(err => {
        logger.error(`Error adding hashtag ${hashtag.text}: ${JSON.stringify(err)}`);
      })
    } else {
      return this.ddp.call({
        methodName: 'me/hashtag/remove',
        params: [hashtag.text, hashtag.type]
      })
      .catch(err => {
        logger.error(`Error removing hashtag ${hashtag.text}: ${JSON.stringify(err)}`);
      })
    }
  }

  render() {
    let hashtag = this.props.hashtag;
    let hashtagColor = hashtag.isMine ? COLORS.taylr : COLORS.emptyHashtag;

    let hashtagButton = (
      <View
        key={this.props.key}
        style={[styles.hashtag, { backgroundColor : hashtagColor }]}>
        <Text style={[styles.hashtagText, SHEET.baseText]}>{hashtag.text}</Text>
      </View>
    );

    return this.props.enableTouch ? (
        <Button onPress={() => this._onHashtagTouch.bind(this)(hashtag)} key={this.props.key}>
          { hashtagButton }
        </Button>
    ) : hashtagButton;
  }
}

var styles = StyleSheet.create({
  hashtag: {
    padding: 8,
    margin: 8,
  },
  hashtagText: {
    color: COLORS.white,
  }
});

module.exports = Hashtag;
