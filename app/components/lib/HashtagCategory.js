let React = require('react-native');

let {
  AppRegistry,
  View,
  Text,
  Image,
  PropTypes,
  StyleSheet
} = React;

import { connect } from 'react-redux/native';
import Routes from '../../nav/Routes';
let SHEET = require('../../CommonStyles').SHEET;

let TappableCard = require('./Card').TappableCard;
let Hashtag = require('./Hashtag');
let Loader = require('./Loader');

function mapStateToProps(state) {
  return {
    categories: state.categories,
    myTags: state.myTags,
    ddp: state.ddp,
  }
}

class HashtagCategory extends React.Component {

  static propTypes = {
    myTags: PropTypes.object.isRequired,
    categories: PropTypes.object.isRequired,
    navigator: PropTypes.object.isRequired,
  };

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
          const route = Routes.instance.getTagListRoute(category);
          this.props.navigator.push(route)}}>
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
    if (this.props.categories.length == 0) {
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


export default connect(mapStateToProps)(HashtagCategory)
