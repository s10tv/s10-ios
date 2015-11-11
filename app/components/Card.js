let React = require('react-native');

let {
  AppRegistry,
  View,
  TouchableHighlight,
  StyleSheet
} = React;

let SHEET = require('./CommonStyles').SHEET;

class BaseCard extends React.Component {
  render() {

    let separator = this.props.hideSeparator ?
      null :
      <View style={SHEET.separator} />;

    return (
      <View style={[this.props.style, styles.cardContainer]}>
        { separator } 
        { this.props.children }
      </View>
    )
  }
}

class Card extends React.Component {
  render() {
    return (
      <BaseCard style={this.props.style}>
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
      <BaseCard style={this.props.style}>
        <TouchableHighlight
          style={styles.card}
          underlayColor="#ffffff"
          onPress={ this.props.onPress }>

            <View>
              { this.props.children }
            </View>
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
