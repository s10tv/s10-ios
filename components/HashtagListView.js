let React = require('react-native');

let {
  AppRegistry,
  View,
  Text,
  ScrollView,
  StyleSheet,
  TouchableHighlight,
  ActivityIndicatorIOS,
} = React;

let SHEET = require('./CommonStyles').SHEET;
let COLORS = require('./CommonStyles').COLORS;
let Card = require('./Card').Card;
let Hashtag = require('./Hashtag');
let SearchBar = require('react-native-search-bar');
let ddp = require('../lib/ddp');

class HashtagListView extends React.Component {
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
      // this.setState({ searchSuggestions: [] })
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

    let hashtags = this.state.hashtags.map((hashtag) => {
      return <Hashtag enableTouch={true} hashtag={ hashtag } />
    });

    let searchSuggestions = this.state.searchSuggestions.map(this._renderSearchSuggestions.bind(this));

    return (
      <View style={SHEET.container}>
        <Card
          style={[SHEET.navTop, SHEET.innerContainer, { flex: 1 }]}
          cardOverride={{ padding: 0 }}
          hideSeparator={true} >

          <SearchBar
            style={{ height: 50, backgroundColor: COLORS.background }}
            placeholder={'Search'}
            hideBackground={true}
            onChangeText={(text) => this._searchTag.bind(this)(text)} />

          <ScrollView
            style={[{ flex: 1 }]}
            contentContainerStyle={styles.hashtagContentContainerStyle}>
              {hashtags}

              <View style={SHEET.bottomTile} />
          </ScrollView>

        </Card>
        <View style={styles.bottomSheet}>
          { searchSuggestions }
        </View>
      </View>
    );
  }
}

var styles = StyleSheet.create({
  loadingView: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  hashtagContentContainerStyle: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    alignItems: 'center',
    justifyContent: 'center'
  },
  bottomSheet: {
    position: 'absolute',
    bottom: 10,
    left: 0,
    right: 0,
  },
  hashtagSuggestion: {
    padding: 10,
    backgroundColor: COLORS.white,
    borderColor: COLORS.emptyHashtag,
    borderTopWidth: 1
  },
  hashtag: {
    padding: 15,
    margin: 10,
  },
  hashtagMine: {
    backgroundColor: COLORS.taylr,
  },
  hashtagNotMine: {
    backgroundColor: COLORS.emptyHashtag,
  },
  hashtagText: {
    color: COLORS.white,
  }
});

module.exports = HashtagListView;