let React = require('react-native');

let {
  AppRegistry,
  View,
  StyleSheet,
} = React;

let ServiceTile = require('./ServiceTile');

class LinkServiceCard extends React.Component {

  render() {
    let services = this.props.services.map((service) => {
      return <ServiceTile key={service._id} 
        navigator={this.props.navigator}
        ddp={this.props.ddp}
        service={service} />
    });

    return(
      <View style={styles.cards}>
        { services } 
      </View>
    )
  }
}

var styles = StyleSheet.create({
  cards: {
    marginVertical: 5,
  },
});

module.exports = LinkServiceCard;