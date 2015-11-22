let React = require('react-native');
let {
  AppRegistry,
  View,
  ScrollView,
  Text,
  Image,
  TouchableOpacity,
  StyleSheet,
} = React;

let Dimensions = require('Dimensions');
let { width, height } = Dimensions.get('window');

let SHEET = require('../CommonStyles').SHEET;
let NetworkComponent = require('./NetworkComponent')
let MoreComponent = require('./MoreComponent');
let SectionTitle = require('../lib/SectionTitle');
let HeaderBanner = require('../lib/HeaderBanner');
let HashtagCategory = require('../lib/HashtagCategory');
let Loader = require("../lib/Loader");
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
    width: width / 4,
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

    var serviceIcons = null;
    var name = null;
    if (me.connectedProfiles) {
      serviceIcons = me.connectedProfiles.map((profile) => {
        return <Image key={profile.id} style={[SHEET.smallIcon, styles.serviceIcon]}
            source={{ uri: profile.icon.url }} />
      });
    }

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
                id: 'edit',
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

    if (!me) {
      console.log('me is undefined');
      return <Loader />
    }

    let coverUrl = 'https://s10tv.blob.core.windows.net/s10tv-prod/defaultbg.jpg';
    if (me && me.cover && me.cover.url) {
      coverUrl = me.cover.url;
    }

    return (
      <View style={SHEET.container}>
        <ScrollView 
          showsVerticalScrollIndicator={false}
          style={[SHEET.navTopTab]}>
          
          <TouchableOpacity onPress={() => {
              this.props.navigator.push({
                id: 'viewprofile',
                title: 'Profile',
                me: me,
              })
            }}>
            <HeaderBanner url={coverUrl} height={ height / 4 }>
              <MeHeader navigator={this.props.navigator} ddp={ddp} me={me} />
            </HeaderBanner>
          </TouchableOpacity>

          <View style={SHEET.innerContainer}>
            <SectionTitle title={'MY SCHOOL'} />
            <NetworkComponent navigator={this.props.navigator} ddp={ddp} />

            <SectionTitle title={'MY HASHTAGS'} />
            <HashtagCategory navigator={this.props.navigator}
              categories={this.props.categories}
              myTags={this.props.myTags}
              ddp={this.ddp} />

            <SectionTitle title={'MORE'} />
            <MoreComponent 
              navigator={this.props.navigator}
              onLogout={this.props.onLogout}
              ddp={this.props.ddp} />
          </View>

          <View style={SHEET.bottomTile} />
        </ScrollView>
      </View>
    )
  }
}

var styles = StyleSheet.create({
  avatar: {
    borderWidth: 2.5,
    borderColor: 'white',
    borderRadius: width / 8,
    height: width / 4,
    width: width / 4,
  },
  meHeader: {
    position: 'absolute',
    backgroundColor: 'rgba(0,0,0,0)',
    top: 0,
    left: 0,
    alignItems: 'center',
    flexDirection: 'row',
    height: height / 4,
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