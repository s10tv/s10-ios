import React, {
  View,
  Text,
  ScrollView,
  InteractionManager,
  TouchableHighlight,
  StyleSheet,
} from 'react-native';

import { connect } from 'react-redux/native';
import SearchBar from 'react-native-search-bar';

import { SCREEN_CATEGORY_LIST } from '../../constants';
import Screen from '../Screen';

let SHEET = require('../../CommonStyles').SHEET;
let COLORS = require('../../CommonStyles').COLORS;
let Card = require('../lib/Card').Card;
let Hashtag = require('../lib/Hashtag');
let Loader = require('../lib/Loader');

const logger = new (require('../../../modules/Logger'))('TagListScreen');

function mapStateToProps(state) {
  return {
    currentScreen: state.currentScreen,
    ddp: state.ddp,
    myTags: state.myTags,
  }
}

class TagListScreen extends Screen {

  static id = SCREEN_CATEGORY_LIST;
  static leftButton = (route, router) => Screen.generateButton('Back', router.pop.bind(router));
  static rightButton = () => null
  static title = (route) => Screen.generateTitleBar(route.props.category.displayName);

  constructor(props = {}) {
    super(props);

    // TODO(qimingfang): consolidate this with redux.
    this.state = {
      searchSuggestions: [],
      suggestions: [],
    };
  }

  componentWillUnmount() {
    if (this.observer) {
      this.observer.dispose();
      this.observer = null;
    }

    if (this.subId) {
      this.props.ddp.unsubscribe(this.subId);
      this.subId = null;
    }
  }

  componentWillMount() {
    let ddp = this.props.ddp;

    return ddp.subscribe({
      pubName: 'suggested-tags',
      params: [this.props.category.type]
    })
    .then((subId) => {
      this.subId = subId;

      let observer = ddp.collections.observe(() => {
        return ddp.collections.suggestions.findOne({ _id: this.props.category.type });
      });

      this.observer = observer;

      observer.subscribe((user) => {
        let suggestions = user.tags.map((suggestion) => {
          suggestion.text = suggestion._id
          return suggestion;
        })

        logger.debug(`searching for lenght = ${suggestions.length}`)

        InteractionManager.runAfterInteractions(() => {
          this.setState({ suggestions: suggestions });
        });
      });
    });
  }

  _searchTag(text) {
    this.setState({ searchText: text });
    if (text.length == 0) {
      this.refs.searchBar.blur();
      this.setState({ searchSuggestions: [] })
    } else {
      this.props.ddp.call({
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
    this.props.ddp.call({
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

    try {
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

      // Suggested Hashtags don't come shipped with param `type`
      // Instead they have `types` which is a list of types that they belong to.
      let type = "default";
      if (hashtag.types && hashtag.types.length > 0) {
        type = hashtag.types[0];
      } else if (hashtag.type) {
        type = hashtag.type;
      }
      hashtag.type = type;

      return <Hashtag key={hashtag.text} ddp={this.props.ddp} enableTouch={true} hashtag={ hashtag } />
    });

    let searchSuggestions = this.state.searchSuggestions.map(
      this._renderSearchSuggestions.bind(this));

    return (
      <View style={SHEET.container}>
        <Card
          style={[SHEET.innerContainer, { flex: 1 }]}
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
  } catch (err) {
    logger.error(err);
  }
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

export default connect(mapStateToProps)(TagListScreen)
