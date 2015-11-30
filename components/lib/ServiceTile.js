let React = require('react-native');
let TaylrAPI = require('react-native').NativeModules.TaylrAPI;

let {
  AppRegistry,
  View,
  Text,
  Image,
  StyleSheet,
} = React;

let SHEET = require('../CommonStyles').SHEET;
let TappableCard = require('./Card').TappableCard;
let Card = require('./Card').Card;
let Analytics = require('../../modules/Analytics');

let FBSDKLogin = require('react-native-fbsdklogin');
let {
  FBSDKLoginManager,
} = FBSDKLogin;

let FBSDKCore = require('react-native-fbsdkcore');
let {
  FBSDKAccessToken,
} = FBSDKCore;

const logger = new (require('../../modules/Logger'))('ServiceTile');

class ServiceTile extends React.Component {

  _handleServiceTouch(service) {
    if (service.status == 'linked') {
      Analytics.track('Remove Integration', {
        name: service.name
      })
    } else if (service.status == 'unlinked') {
      Analytics.track('Add Integration', {
        name: service.name
      })
    }
    this.props.navigator.push({
      id: 'linkservice',
      title: "Add Integration",
      link: service.url,
      integration: service,
    })
  }

  capitalizeFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
  }

  render() {
    let service = this.props.service;
    
    let icon = service.status == 'linked' ?
      <Image style={[SHEET.icon]} source={require('../img/ic-checkmark.png')} /> :
      <Image style={[SHEET.icon]} source={require('../img/ic-add.png')} />

    let display = service.status == 'linked' ?
      <Text style={[styles.serviceId, SHEET.baseText]}>{service.username}</Text> : null;

    let cardInfo = (
      <View style={styles.service}>
        <Image source={{ uri: service.icon.url }} style={[SHEET.icon]} />
        <View style={styles.serviceDesc}>
          <Text style={[SHEET.subTitle, SHEET.baseText]}>
            {this.capitalizeFirstLetter(service.name)}
          </Text>
          { display }
        </View>
        {icon}
      </View>
    )

    if (service.name === 'facebook') {
      if (service.status == 'unlinked') {
        return (
          <TappableCard
            {...this.props}
            onPress={(event) => {

              // TODO: clean up duplicated code. This is ridiculous.
              // https://app.asana.com/0/34520227311296/69377281916556
              let permissions = ['email', 'public_profile', 'user_about_me', 
              'user_birthday', 'user_education_history',
              'user_friends', 'user_location', 'user_photos', 'user_posts']


              FBSDKLoginManager.logInWithReadPermissions(permissions, (error, result) => {
                if (error) {
                  logger.error(`Error logging in with Facebook ${JSON.stringify(error)}`);
                  alert('Error logging you in :C Please try again later.');
                } else {
                  if (!result.isCancelled) {
                    FBSDKAccessToken.getCurrentAccessToken((accessToken) => {
                      if (accessToken && accessToken.tokenString) {
                        this.props.ddp.call({
                          methodName: 'me/service/add',
                          params: ['facebook', accessToken.tokenString]
                        })
                        .catch(err => {
                          logger.error(JSON.stringify(error));
                       })
                      }
                    });
                  } else {
                    logger.info('Welcome: Cancelled FB Verification'); 
                  }
                }
              });
            }}>
            { cardInfo }
          </TappableCard>
        )
      } else {
        return <Card>{ cardInfo }</Card>
      }
    } else {
      return (
        <TappableCard
          {...this.props}
          onPress={(event) => { return this._handleServiceTouch.bind(this)(service)}}>
          { cardInfo }
        </TappableCard>
      )
    }
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