import React, {
  AppRegistry,
  View,
  TouchableHighlight,
  StyleSheet
} from 'react-native';

import { SHEET } from '../../CommonStyles';

class BaseCard extends React.Component {
  render() {

    let separator = this.props.hideSeparator ?
      null :
      <View style={SHEET.separator} />;

    return (
      <View {...this.props} style={[this.props.style, styles.cardContainer]}>
        { separator }
        { this.props.children }
      </View>
    )
  }
}

class Card extends React.Component {
  render() {
    return (
      <BaseCard hideSeparator={this.props.hideSeparator} {...this.props}>
        <View style={[styles.card, this.props.cardOverride]}>
          { this.props.children}
        </View>
      </BaseCard>
    )
  }
}

class TappableCard extends React.Component {
  render() {
    return (
      <BaseCard hideSeparator={this.props.hideSeparator}
        {...this.props}>
          <TouchableHighlight
            style={[styles.card, this.props.cardOverride]}
            underlayColor="#ffffff"
            onPress={ this.props.onPress }>
                { this.props.children }
          </TouchableHighlight>
      </BaseCard>
    )
  }
}

var styles = StyleSheet.create({
  cardContainer: {
    flex: 1,
    backgroundColor: 'white',
  },
  card: {
    flex: 1,
    padding: 15,
  },

});

exports.Card = Card;
exports.TappableCard = TappableCard;
