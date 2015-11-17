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

class HashtagListView extends React.Component {
  constructor(props: {}) {
    super(props);
    this.ddp = props.ddp;
    this.state = {
      loading: true,
      hashtags: [],
      searchSuggestions: [],
    }
  }

  componentWillUnmount() {
    if (this.state.observer) {
      this.state.observer.dispose();
    }
  }

  componentWillMount() {
    let ddp = this.ddp;

    return ddp.subscribe({
      pubName: 'suggested-hashtags',
      params: [this.props.category.type]
    })
    .then((res) => {
      let observer = ddp.collections.observe(() => {
        let hashtags = [];
        if (ddp.collections.hashtags) {
          hashtags = ddp.collections.hashtags.find({ type: this.props.category.type });
        }
        return hashtags;
      });

      this.setState({observer: observer});

      observer.subscribe((results) => {
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
    this.ddp.call({
      methodName: 'hashtags/search',
      params: [text, this.props.category.type]
    })
    .then((tags) => {
      this.setState({ searchSuggestions: tags })
    })
  }

  _addSearchSuggestion(hashtag) {
    this.ddp.call({
      methodName: 'me/hashtag/add',
      params: [hashtag.text, hashtag.type]
    })
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
      return <Hashtag ddp={this.ddp} enableTouch={true} hashtag={ hashtag } />
    });

    let searchSuggestions = this.state.searchSuggestions.map(this._renderSearchSuggestions.bind(this));

    return (
      <View style={SHEET.container}>
        <Card
          style={[SHEET.navTop, SHEET.innerContainer, { flex: 1 }]}
          cardOverride={{ padding: 0 }}
          hideSeparator={true} >

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