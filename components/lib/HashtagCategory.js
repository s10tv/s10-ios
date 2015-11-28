let React = require('react-native');

let {
  AppRegistry,
  View,
  Text,
  Image,
  StyleSheet
} = React;

let SHEET = require('../CommonStyles').SHEET;

let TappableCard = require('./Card').TappableCard;
let Hashtag = require('./Hashtag');
let Loader = require('./Loader');
let Analytics = require('../../modules/Analytics');

class HashtagCategory extends React.Component {
  _handleCategoryTouch(category) {
    Analytics.track('Edit Hashtags', {
      category: category.displayName
    });
    this.props.navigator.push({
      id: 'addhashtag',
      title: category.displayName,
      category: category
    })
  }

  _renderItem(category) {

    var myTagsRendered = [];
    if (this.props.myTags) {
      myTagsRendered = this.props.myTags.filter(tag => {
        return tag.type == category._id
      }).map(hashtag => {
        return <Hashtag 
          key={hashtag.text}
          ddp={this.props.ddp}
          enableTouch={false}
          hashtag={ hashtag } />
      });
    }

    let icon = myTagsRendered.length == 0 ?
      <Image style={SHEET.icon} source={require('../img/ic-add.png')} /> :
      <Image style={SHEET.icon} source={require('../img/ic-checkmark.png')} />

    return (
      <TappableCard key={category.displayName} onPress={(event) => { 
          return this._handleCategoryTouch.bind(this)(category)}}>
        <View>
          <View style={[styles.categoryHeader]}>
            {icon}
            <Text style={[styles.categoryDisplayName, SHEET.subTitle, SHEET.baseText]}>{category.displayName}</Text>
          </View>
          <View style={styles.myHashtags}>
            { myTagsRendered }
          </View>
        </View>
      </TappableCard>
    )
  }

  render() {
    if (!this.props.categories) {
      return <Loader />;
    }

    let rows = this.props.categories.map(category => {
      return this._renderItem.bind(this)(category)
    })

    return (
      <View style={this.props.style}>
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
    marginLeft: 10,
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