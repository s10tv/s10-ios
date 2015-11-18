let React = require('react-native');
var Button = require('react-native-button');

let {
  AppRegistry,
  Navigator,
  Text,
  TouchableOpacity,
  StyleSheet,
} = React;

let BaseTaylrNavigator = require('../lib/BaseTaylrNavigator');
let DiscoverScreen = require('./DiscoverScreen');
let Activities = require('../lib/Activities');
let SHEET = require('../CommonStyles').SHEET;

class DiscoverNavigator extends BaseTaylrNavigator {
  constructor(props) {
    super(props);
    this.ddp = props.ddp;
  }

  _leftButton(route, navigator, index, navState) {
    if (route.id) {
      return (
        <TouchableOpacity
          onPress={() => navigator.pop()}
          style={SHEET.navBarLeftButton}>
          <Text style={[SHEET.navBarText, SHEET.navBarButtonText, SHEET.baseText]}>
            Back
          </Text>
        </TouchableOpacity>
      );
    }
  }

  _rightButton(route, navigator, index, navState) {
    return null;
  }

  renderDiscoverScene(route, nav) {
    switch (route.id) {
      case 'viewprofile':
        return <Activities navigator={nav} ddp={this.ddp} 
          me={route.candidateUser} 
          loadActivities={true} />
      case 'sendMessage':
        return <ContainerView sbName="Conversation" />
      default:
        return (
          <DiscoverScreen navigator={nav} ddp={this.ddp} 
            candidate={this.props.candidate}
            users={this.props.users}
            settings={this.props.settings} />
        );
    } 
  }

  render() {
    return (
      <Navigator
        itemWrapperStyle={styles.navWrap}
        style={styles.nav}
        renderScene={this.renderDiscoverScene.bind(this)}
        configureScene={(route) => ({
          ...Navigator.SceneConfigs.HorizontalSwipeJump,
          gestures: {}, // or null
        })}
        initialRoute={{
          title: 'Discover',
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
  },
  nav: {
    flex: 1,
  },
  navBar: {
    backgroundColor: '#64369C',
  }
});

module.exports = DiscoverNavigator;