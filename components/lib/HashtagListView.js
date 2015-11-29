let React = require('react-native');

let {
  AppRegistry,
  View,
  Text,
  ScrollView,
  TouchableHighlight,
  StyleSheet,
} = React;

let SHEET = require('../CommonStyles').SHEET;
let COLORS = require('../CommonStyles').COLORS;
let Card = require('./Card').Card;
let Hashtag = require('./Hashtag');
let Loader = require('./Loader');
let SearchBar = require('react-native-search-bar');

const logger = new (require('../../modules/Logger'))('HashtagListView');

class HashtagListView extends React.Component {
  constructor(props: {}) {
    super(props);
    this.ddp = props.ddp;
    this.state = {
      loading: true,
      searchText: '',
      suggestions: [],
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
      pubName: 'suggested-tags',
      params: [this.props.category.type]
    })
    .then((res) => {
      let observer = ddp.collections.observe(() => {
        let hashtags = [];
        if (ddp.collections.suggestions) {
          hashtags = ddp.collections.suggestions.findOne({ _id: this.props.category.type });
        }
        return hashtags;
      });

      this.setState({observer: observer});

      observer.subscribe((user) => {
        let suggestions = user.tags.map((suggestion) => {
          suggestion.text = suggestion._id
          return suggestion;
        })
        this.setState({ suggestions: suggestions });
      });
    });
  }

  _searchTag(text) {
    this.setState({ searchText: text });
    if (text.length == 0) {
      this.refs.searchBar.blur();
      this.setState({ searchSuggestions: [] })
    } else {
      this.ddp.call({
        methodName: 'hashtags/search',
        params: [text, this.props.category.type]
      })
      .then((tags) => {
        this.setState({ searchSuggestions: tags })
      })
      .catch(err => {
        logger.error(`Error in search tag: ${JSON.stringify(err)}`);
      })
    }
  }

  _addSearchSuggestion(hashtag) {
    this.ddp.call({
      methodName: 'me/hashtag/add',
      params: [hashtag.text, hashtag.type]
    })
    .catch(err => {
      logger.error(`Error in adding search suggestion: ${JSON.stringify(err)}`);
    })

    this.setState({ searchSuggestions: [] })
    this.setState({ searchText: '' });
    this.refs.searchBar.blur();
  }

  _renderSearchSuggestions(hashtag) {
    return (
      <TouchableHighlight
          key={hashtag.text}
          underlayColor={COLORS.taylr}
          onPress={(event) => { return this._addSearchSuggestion.bind(this)(hashtag)}}>
        <View style={styles.hashtagSuggestion}>
          <Text style={SHEET.baseText}>{ hashtag.text }</Text>
        </View>
      </TouchableHighlight>
    )
  }

  render() {
    if (this.state.suggestions.length == 0) {
      return <Loader />
    }

    let myTags = this.props.myTags;

    var myTagsRendered = null;
    if (myTags) {
      myTagsRendered = myTags.filter(tag => {
        return tag.type == this.props.category.type
      }).map(hashtag => {
        return <Hashtag 
          key={hashtag.text}
          ddp={this.props.ddp}
          enableTouch={true}
          hashtag={ hashtag } />
      });
    }

    let myTagIds = [];
    if (myTags) {
      myTagIds = myTags.map(tag => {
        return tag.text;
      })
    }

    let hashtags = this.state.suggestions.filter((hashtag) => {
      return myTagIds.indexOf(hashtag._id) < 0;
    })
    .map((hashtag) => {
      return <Hashtag key={hashtag.text} ddp={this.ddp} enableTouch={true} hashtag={ hashtag } />
    });

    let searchSuggestions = this.state.searchSuggestions.map(this._renderSearchSuggestions.bind(this));

    return (
      <View style={SHEET.container}>
        <Card
          style={[SHEET.navTop, SHEET.innerContainer, { flex: 1 }]}
          cardOverride={{ padding: 0 }}
          hideSeparator={true} >

          <View style={{ backgroundColor: COLORS.background }}>
          <SearchBar
            ref='searchBar'
            text={this.state.searchText}
            style={{ height: 50 }}
            placeholder={'Search'}
            hideBackground={true}
            onChangeText={(text) => this._searchTag.bind(this)(text)} />
          </View>

          <ScrollView
            showsVerticalScrollIndicator={false}
            style={[{ flex: 1 }]}
            contentContainerStyle={styles.hashtagContentContainerStyle}>
              {myTagsRendered}
              {hashtags}

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
  hashtagContentContainerStyle: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    alignItems: 'center',
    justifyContent: 'center'
  },
  bottomSheet: {
    position: 'absolute',
    top: 110,
    left: 0,
    right: 0,
  },
  hashtagSuggestion: {
    paddingHorizontal: 10,
    paddingVertical: 20,
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