let React = require('react-native');
let TaylrAPI = require('react-native').NativeModules.TaylrAPI;
let {
  AppRegistry,
  View,
  ScrollView,
  Text,
  Image,
  TouchableOpacity,
  TouchableHighlight,
  ActionSheetIOS,
  Navigator,
  StyleSheet,
} = React;

let SHEET = require('../CommonStyles').SHEET;
let Network = require('./Network')
let ContactUs = require('./ContactUs');
let SectionTitle = require('../lib/SectionTitle');
let HeaderBanner = require('../lib/HeaderBanner');
let HashtagCategory = require('../lib/HashtagCategory');
let Button = require('react-native-button');

class MeButton extends React.Component {
  render() {
    return(
      <View style={[buttonStyles.container, this.props.style]}>
        <Button
          onPress={this.props.onPress}>
            <View style={buttonStyles.button}>
              <Text style={[buttonStyles.buttonText, SHEET.baseText]}>
                { this.props.text }
              </Text>
            </View>
        </Button> 
      </View>
    ) 
  }
}
var buttonStyles = StyleSheet.create({
  container: {
    backgroundColor: 'black',
    opacity: 0.6,
    borderWidth: 1,
    borderColor: 'white',
    alignItems: 'center',
    borderRadius: 2,
  },
  button: {
    width: 100,
  },
  buttonText: {
    flex: 1,
    paddingVertical: 5,
    fontSize:16,
    color:'white',
    textAlign: 'center',
  }
});

class MeHeader extends React.Component {

  render() {
    let me = this.props.me;
    let serviceIcons = me.connectedProfiles.map((profile) => {
      return (<Image style={[SHEET.smallIcon, styles.serviceIcon]}
          source={{ uri: profile.icon.url }} />);
    });

    return (
      <View style={styles.meHeader}>
        <Image style={styles.avatar} source={{ uri: me.avatar.url }} />
        <View style={styles.headerContent}>
          <Text style={[styles.headerText, SHEET.baseText]}>
            {me.firstName} {me.lastName} {me.gradYear}
          </Text>
          <View style={styles.headerContentLineItem}>
            { serviceIcons }
          </View>
          <View style={styles.headerContentLineItem}>
            <MeButton text={'View'} onPress={() => {
               this.props.navigator.push({
                id: 'viewprofile',
                title: 'Profile',
                me: me,
              })
            }} />
            <MeButton style={{ left:10 }} text={'Edit'} onPress={() => {
              this.props.navigator.push({
                id: 'editprofile',
                title: 'Edit Profile',
                userId: me._id,
                me: me,
              })}} />
          </View>
        </View>
      </View>
    )
  }
}

class Me extends React.Component {
  render() {
    let ddp = this.props.ddp;
    let me = this.props.me;

    if (!me){
      return (<Text>Loading ...</Text>);
    } else {
      return (
        <View style={SHEET.container}>
          <ScrollView style={[SHEET.navTop, SHEET.bottomTile]}>
            <HeaderBanner url={me.cover.url} height={170}>
              <MeHeader navigator={this.props.navigator} ddp={ddp} me={me} />
            </HeaderBanner>

            <Network navigator={this.props.navigator} ddp={ddp} />

            <SectionTitle title={'MY HASHTAGS'} />
            <HashtagCategory navigator={this.props.navigator}
              style={SHEET.innerContainer}
              categories={this.props.categories}
              myTags={this.props.myTags}
              ddp={this.ddp} />

            <ContactUs navigator={this.props.navigator} />

            <View style={SHEET.bottomTile} />
          </ScrollView>
        </View>
      )
    }
  }
}

var styles = StyleSheet.create({
  avatar: {
    borderRadius: 52.5,
    height: 105,
    width: 105,
  },
  meHeader: {
    position: 'absolute',
    backgroundColor: 'rgba(0,0,0,0)',
    top: 0,
    left: 0,
    alignItems: 'center',
    flexDirection: 'row',
    height: 170,
    marginHorizontal: 15,
  },
  headerContent: {
    flexDirection: 'column',
    left: 15,
  },
  headerContentLineItem: {
    flex: 1,
    flexDirection: 'row',
    marginTop: 10,
  },
  headerText: {
    color: 'white',
    fontSize: 24
  },
  serviceIcon: {
    marginRight: 5,
  },
});

module.exports = Me;