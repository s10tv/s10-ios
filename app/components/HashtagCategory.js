let React = require('react-native');
let {
  AppRegistry,
  View,
  Text,
  Image,
  TouchableHighlight,
  ScrollView,
  StyleSheet
} = React;
let ddp = require('../lib/ddp');

let Hashtag = require('./Hashtag');

class HashtagCategory extends React.Component {
  constructor(props: {}) {
    super(props);
    this.state = {
      myTags: [],
      categories: []
    };
  }

  componentWillMount() {
    ddp.initialize()
    .then(() => {
      return ddp.loginWithToken('vU8rq_HWmJm7LNHx78anzipsNu9XUYY26jsWvn8Bfdx') 
    })
    .then(() => {
      return ddp.subscribe('hashtag-categories')
    })
    .then((res) => {
      console.log("[QIMING] HashtagCategory subscribing")
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
        console.log(results);
        this.setState({ myTags: results });
      });
    })
  }

  _handleCategoryTouch(category) {
    this.props.navigator.push({
      title: category.displayName,
      component: Hashtag,
      passProps: {
        category: category
      }
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
      <View key={category._id}>
        <TouchableHighlight
          underlayColor="#ffffff"
          onPress={(event) => { return this._handleCategoryTouch.bind(this)(category)}}>
            <View key={category._id} style={styles.category}>
              <View style={styles.categoryHeader}>
                <Text style={styles.categoryDisplayName}>{category.displayName}</Text>
                {icon}
              </View>
              <View style={styles.myHashtags}>
                { myTagsRendered }
              </View>
            </View>
          </TouchableHighlight>
        <View style={styles.separator} />
      </View>
    )
  }

  render() {
    let rows = this.state.categories.map(category => {
      return this._renderItem.bind(this)(category)
    })

    return (
      <ScrollView style={styles.container}>
        {rows}
      </ScrollView>
    );
  }
}

var styles = StyleSheet.create({
  container: {
    padding:10
  },
  category: {
    flex: 1,
    paddingHorizontal: 10
  },
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
    backgroundColor: "#4A148C",
  },
  hashtagText: {
    color: "#ffffff"
  },
  separator: {
    backgroundColor: "#e0e0e0",
    marginVertical: 10,
    height: 0.5
  },
});

module.exports = HashtagCategory;