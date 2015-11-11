let React = require('react-native');
var Button = require('react-native-button');

let {
  AppRegistry,
  View,
  Text,
  Image,
  TouchableOpacity,
  Navigator,
  WebView,
  StyleSheet,
} = React;

let ddp = require('../lib/ddp');
let Me = require('./Me');
let MeEdit = require('./MeEdit');
let HashtagCategory = require('./HashtagCategory');
let Hashtag = require('./Hashtag');
var EventEmitter = require('EventEmitter');

class LayoutContainer extends React.Component {

  constructor(props: {}) {
    super(props);
    this.state = {
      modalVisible: false
    }
    this.eventEmitter = new EventEmitter();
  }

  _leftButton(route, navigator, index, navState) {
    if (route.id) {
      return (
        <TouchableOpacity
          onPress={() => navigator.pop()}
          style={styles.navBarLeftButton}>
          <Text style={[styles.navBarText, styles.navBarButtonText]}>
            Back
          </Text>
        </TouchableOpacity>
      );
    }
  }

  _rightButton(route, navigator, index, navState) {
    return(
      <View style={styles.navBarRightButton}>
        <Button onPress={() => { 
          console.log('should show action sheet');
        }}>
          <Image style={{ flex: 1, width: 40 }} resizeMode="contain" source={require('./img/ic-more-png.png')} />
        </Button>
      </View>
    )
  }

  _title (route, navigator, index, navState) {
    return (
      <Text style={[styles.navBarText, styles.navBarTitleText]}>
        {route.title}
      </Text>
    );
  }

  renderScene(route, nav) {
    switch (route.id) {
      case 'hashtag':
        return <Hashtag navigator={nav} category={route.category} />;
      case 'servicelink':
        return <WebView
          style={styles.webView}
          startInLoadingState={true}
          url={route.link} />;
      case 'editprofile':
        return <MeEdit navigator={nav} userId={route.userId} />
      default:
        return (
          <Me navigator={nav} eventEmitter={this.eventEmitter} />
        );
    }
  }

  render() {
    return (
      <Navigator
        itemWrapperStyle={styles.navWrap}
        style={styles.nav}
        renderScene={this.renderScene.bind(this)}
        configureScene={(route) => Navigator.SceneConfigs.FloatFromRight}
        initialRoute={{
          title: 'Me',
        }}
        navigationBar={
          <Navigator.NavigationBar
            routeMapper={{
              LeftButton: this._leftButton.bind(this),
              RightButton: this._rightButton.bind(this),
              Title: this._title.bind(this)
            }}
            style={styles.navBar} />
        }>
      </Navigator>
    )
  }
}

var styles = StyleSheet.create({
  navWrap: {
    flex: 1,
    marginTop: 15
  },
  webView: {
    marginTop: 64,
    paddingTop: 64,
  },
  nav: {
    flex: 1,
  },
  moreButton: {
    width: 200,
    height: 200,
    position: 'absolute',
    top: 0,
    right: 0
  },
  navBar: {
    backgroundColor: '#64369C',
  },
  navBarTitleText: {
    fontSize: 20,
    color:  'white',
    fontWeight: '500',
    marginVertical: 9,
  },
  navBarText: {
    color: 'white',
    fontSize: 16,
    marginVertical: 10,
  },
  navBarLeftButton: {
    paddingLeft: 10,
  },
  navBarRightButton: {
    flex: 1,
    flexDirection: 'row',
    height: 64,
    alignItems: 'center',
    paddingRight: 10,
  },
});

module.exports = LayoutContainer;