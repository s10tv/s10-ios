let React = require('react-native');

let {
  AppRegistry,
  View,
  Text,
  ScrollView,
  StyleSheet
} = React;

let ddp = require('./ddp');

class HashtagContainer extends React.Component {
  constructor(props: {}) {
    super(props);
    this.state = {
      hashtags:[]
    }
  }

  componentWillMount() {
    ddp.subscribe('suggested-hashtags', [this.props.category.type])
    .then((res) => {
      let hashtagObserver = ddp.collections.observe(() => {
        let hashtags = [];
        if (ddp.collections.hashtags) {
          hashtags = ddp.collections.hashtags.find({ type: this.props.category.type });
        }
        return hashtags;
      });

      this.setState({hashtagObserver: hashtagObserver});

      hashtagObserver.subscribe((results) => {
        this.setState({ hashtags: results });
      });
    });
  }

  _onHashtagTouch(hashtag) {
    if (!hashtag.isMine) {
      return ddp.call('me/hashtag/add', [hashtag.text, hashtag.type])
    } else {
      return ddp.call('me/hashtag/remove', [hashtag.text, hashtag.type])
    }
  }

  _renderHashtag(hashtag) {
    let backgroundColor = hashtag.isMine ? styles.hashtagMine : styles.hashtagNotMine;

    return (
      <View style={[styles.hashtag, backgroundColor]} onTouchEnd={(event) => this._onHashtagTouch.bind(this)(hashtag)}>
        <Text style={styles.hashtagText}>{hashtag.text}</Text>
      </View>
    )
  }

  render() {
    let hashtags = this.state.hashtags.map(this._renderHashtag.bind(this));

    return (
      <ScrollView
        contentContainerStyle={styles.hashtagContentContainerStyle}>
          {hashtags}
      </ScrollView>
    );
  }
}

var styles = StyleSheet.create({
  hashtagContentContainerStyle: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    alignItems: 'flex-start'
  },
  hashtag: {
    padding: 15,
    margin: 10,
  },
  hashtagMine: {
    backgroundColor: "#4A148C",
  },
  hashtagNotMine: {
    backgroundColor: "#cccccc",
  },
  hashtagText: {
    color: 'white',
  }
});

module.exports = HashtagContainer;