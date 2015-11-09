let React = require('react-native');
let Overlay = require('react-native-overlay');

let {
  AppRegistry,
  View,
  Text,
  ScrollView,
  StyleSheet,
  TouchableHighlight,
  ActivityIndicatorIOS,
} = React;

let SearchBar = require('react-native-search-bar');
let ddp = require('../lib/ddp');

class NavButton extends React.Component {
  render() {
    return (
      <TouchableHighlight
        style={styles.button}
        underlayColor="#B5B5B5"
        onPress={this.props.onPress}>
        <Text style={styles.buttonText}>{this.props.text}</Text>
      </TouchableHighlight>
    );
  }
}

class HashtagContainer extends React.Component {
  constructor(props: {}) {
    super(props);
    this.state = {
      loading: true,
      hashtags: [],
      searchSuggestions: [],
    }
  }

  componentWillMount() {
    return ddp.subscribe('suggested-hashtags', [this.props.category.type])
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
        results.sort((x, y) => { 
          if (x.isMine === y.isMine) {
            return 0 
          } else {
            if (x.isMine) {
              return -1
            } else {
              return 1;
            }
          }
        });

        this.setState({ hashtags: results });
        this.setState({ loading: false });
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

  _searchTag(text) {
    ddp.call('hashtags/search', [text, this.props.category.type])
    .then((tags) => {
      this.setState({ searchSuggestions: tags })
    })
  }

  _addSearchSuggestion(hashtag) {
    ddp.call('me/hashtag/add', [hashtag.text, hashtag.type])
    .then((tags) => {
      console.log(hashtag);
      this.setState({ searchSuggestions: [] })
    })
  }

  _renderSearchSuggestions(hashtag) {
    return (
      <TouchableHighlight
          underlayColor="#ffffff"
          onPress={(event) => { return this._addSearchSuggestion.bind(this)(hashtag)}}>
        <View style={styles.hashtagSuggestion}>
          <Text>{ hashtag.text }</Text>
        </View>
      </TouchableHighlight>
    )
  }

  _renderLoadingView() {
    return (
      <View style={styles.loadingView}>
        <ActivityIndicatorIOS
          size="large"
          animating={true}
          style={styles.spinner} />
      </View>
    )
  }

  render() {
    if (this.state.loading) {
      return this._renderLoadingView()
    }

    let hashtags = this.state.hashtags.map(this._renderHashtag.bind(this));
    let searchSuggestions = this.state.searchSuggestions.map(this._renderSearchSuggestions.bind(this));

    return (
      <View style={styles.container}>
        <NavButton
          onPress={() => {
            this.props.navigator.pop();
          }}
          text="Exit NavigationBar Example" />
      </View>
    );
  }
}

var styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingTop: 100,
  },
  loadingView: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  hashtagContainerStyle: {
    paddingTop: 64,
  },
  hashtagContentContainerStyle: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    alignItems: 'flex-start'
  },
  bottomSheet: {
    position: 'absolute',
    bottom: 29,
    left: 0,
    right: 0,
  },
  hashtagSuggestion: {
    padding: 10,
    backgroundColor: "#ffffff",
    borderColor: "#cccccc",
    borderTopWidth: 1
  },
  searchBoxContainer: {
    paddingTop: 1,
    backgroundColor: "#cccccc"
  },
  hashtag: {
    padding: 15,
    margin: 10,
    position: 'relative',
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