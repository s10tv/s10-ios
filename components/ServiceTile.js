let React = require('react-native');
let TaylrAPI = require('react-native').NativeModules.TaylrAPI;

let {
  AppRegistry,
  View,
  Text,
  Image,
  StyleSheet,
} = React;

let SHEET = require('./CommonStyles').SHEET;
let TappableCard = require('./Card').TappableCard;

class ServiceTile extends React.Component {

  _handleServiceTouch(link) {
    this.props.navigator.push({
      id: 'servicelink',
      title: "Link Service",
      link: link
    })
  }

  render() {
    let service = this.props.service;
    
    let icon = service.status == 'linked' ?
      <Image style={[SHEET.icon]} source={require('./img/ic-checkmark.png')} /> :
      <Image style={[SHEET.icon]} source={require('./img/ic-add.png')} />

    let display = service.status == 'linked' ?
      <Text style={[styles.serviceId, SHEET.baseText]}>{service.username}</Text> : null;

    return (
      <TappableCard 
        onPress={(event) => { return this._handleServiceTouch.bind(this)(service.url)}}>
          <View style={styles.service}>
            <Image source={{ uri: service.icon.url }} style={[SHEET.icon]} />
            <View style={styles.serviceDesc}>
              <Text style={[SHEET.subTitle, SHEET.baseText]}>{service.name}</Text>
              { display }
            </View>
            {icon}
          </View>
      </TappableCard>
    )
  }
}

var styles = StyleSheet.create({
  service: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
  },
  serviceDesc: {
    flex: 1,
    left: 15,
  },
  serviceId: {
    color: '#000000',
    fontSize: 15, 
  },
});

module.exports = ServiceTile;