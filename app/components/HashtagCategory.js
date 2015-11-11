let React = require('react-native');

let {
  AppRegistry,
  View,
  Text,
  Image,
  TouchableHighlight,
  StyleSheet
} = React;
let ddp = require('../lib/ddp');

let Hashtag = require('./Hashtag');
let TappableCard = require('./Card').TappableCard;
let SHEET = require('./CommonStyles').SHEET;

class HashtagCategory extends React.Component {
  constructor(props: {}) {
    super(props);
    this.state = {
      myTags: [],
      categories: []
    };
  }

  componentWillMount() {
    return ddp.subscribe('hashtag-categories')
    .then((res) => {
      let categoryObserver = ddp.collections.observe(() => {
        let categories = [];
        if (ddp.collections.categories) {
          categories = ddp.collections.categories.find({});
        }
        return categories;
      });

      this.setState({categoryObserver: categoryObserver});

      categoryObserver.subscribe((results) => {
        this.setState({ categories: results });
      });
    })
    .then(() => {
      return ddp.subscribe('my-hashtags')
    })
    .then((res) => {
      let myHashtagObserver = ddp.collections.observe(() => {
        let myTags = [];
        if (ddp.collections.hashtags) {
          myTags = ddp.collections.hashtags.find({ isMine: true });
        }
        return myTags;
      });

      this.setState({ myHashtagObserver: myHashtagObserver });

      myHashtagObserver.subscribe((results) => {
        this.setState({ myTags: results });
      });
    })
  }

  _handleCategoryTouch(category) {
    this.props.navigator.push({
      id: 'hashtag',
      title: category.displayName,
      category: category
    })
  }

  _renderItem(category) {
    let myTagsRendered = this.state.myTags.filter(tag => {
      return tag.type == category._id
    }).map(hashtag => {
      return (
        <View key={hashtag._id} style={styles.hashtagContainer}>
          <Text style={styles.hashtagText}>{hashtag.text}</Text>
        </View>
      )
    });

    let icon = myTagsRendered.length == 0 ?
      <Image style={styles.categoryIcon} source={{ uri: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-warning.png' }} /> :
      <Image style={styles.categoryIcon} source={{ uri: 'https://s10tv.blob.core.windows.net/s10tv-prod/ic-checkmark.png' }} />

    return (
      <TappableCard onPress={(event) => { return this._handleCategoryTouch.bind(this)(category)}}>
        <View style={styles.categoryHeader}>
          <Text style={styles.categoryDisplayName}>{category.displayName}</Text>
          {icon}
        </View>
        <View style={styles.myHashtags}>
          { myTagsRendered }
        </View>
      </TappableCard>
    )
  }

  render() {
    let rows = this.state.categories.map(category => {
      return this._renderItem.bind(this)(category)
    })

    return (
      <View style={SHEET.innerContainer}>
        {rows}
      </View>
    );
  }
}

var styles = StyleSheet.create({
  categoryHeader: {
    flexDirection: 'row',
  },
  categoryIcon: {
    width: 30,
    height: 30,
  },
  categoryDisplayName: {
    flex: 1,
  },
  myHashtags: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    alignItems: 'flex-start'
  },
  hashtagContainer: {
    padding: 15,
    margin: 10,
    backgroundColor: "#64369C",
  },
  hashtagText: {
    color: "#ffffff"
  },
  separator: {
    backgroundColor: "#e0e0e0",
    height: 1
  },
});

module.exports = HashtagCategory;