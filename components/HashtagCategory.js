let React = require('react-native');

let {
  AppRegistry,
  View,
  Text,
  Image,
  TouchableHighlight,
  StyleSheet
} = React;

let TappableCard = require('./Card').TappableCard;
let SectionTitle = require('./SectionTitle');
let Hashtag = require('./Hashtag');
let SHEET = require('./CommonStyles').SHEET;

class HashtagCategory extends React.Component {
  constructor(props: {}) {
    super(props);
    this.ddp = props.ddp;
    this.state = {
      myTags: [],
      categories: []
    };
  }

  componentWillMount() {
    let ddp = this.ddp;

    return ddp.subscribe({ pubName: 'hashtag-categories' })
    .then((res) => {
      let categoryObserver = ddp.collections.observe(() => {
        let categories = [];
        if (ddp.collections.categories) {
          categories = ddp.collections.categories.find({});
        }
        return categories;
      });
      categoryObserver.subscribe((results) => {
        this.setState({ categories: results });
      });
    })
    .then(() => {
      return ddp.subscribe({ pubName: 'my-hashtags' })
    })
    .then((res) => {
      let myHashtagObserver = ddp.collections.observe(() => {
        let myTags = [];
        if (ddp.collections.hashtags) {
          myTags = ddp.collections.hashtags.find({ isMine: true });
        }
        return myTags;
      });
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
      return <Hashtag key={hashtag.value} ddp={this.ddp} enableTouch={false} hashtag={ hashtag } />
    });

    let icon = myTagsRendered.length == 0 ?
      <Image style={SHEET.icon} source={require('./img/ic-add.png')} /> :
      <Image style={SHEET.icon} source={require('./img/ic-checkmark.png')} />

    return (
      <TappableCard key={category.displayName} onPress={(event) => { return this._handleCategoryTouch.bind(this)(category)}}>
        <View style={[styles.categoryHeader]}>
          <Text style={[styles.categoryDisplayName, SHEET.subTitle, SHEET.baseText]}>{category.displayName}</Text>
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
        <SectionTitle title={'MY HASHTAGS'} />
        {rows}
      </View>
    );
  }
}

var styles = StyleSheet.create({
  categoryHeader: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  categoryDisplayName: {
    flex: 1,
  },
  myHashtags: {
    marginHorizontal: -8, // offsets the hashtag.
    marginVertical: 4,
    flexDirection: 'row',
    flexWrap: 'wrap',
    alignItems: 'flex-start'
  },
});

module.exports = HashtagCategory;