let React = require('react-native');

let {
  AppRegistry,
  View,
  StyleSheet,
} = React;

let ServiceTile = require('./ServiceTile');
let Loader = require('./Loader');

class LinkServiceCard extends React.Component {

  render() {
    let services = null;
    if (this.props.services) {
      services = this.props.services.map((service) => {
        return <ServiceTile key={service._id} 
          navigator={this.props.navigator}
          ddp={this.props.ddp}
          service={service} />
      });
    } else {
      services = (
        <Loader />
      )
    }

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