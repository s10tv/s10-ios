let React = require('react-native');
var Button = require('react-native-button');

let {
  AppRegistry,
  Navigator,
  Text,
  TouchableOpacity,
  StyleSheet,
} = React;

let Discover = require('./Discover');
let Activities = require('../lib/Activities');
let SHEET = require('../CommonStyles').SHEET;

class DiscoverNavigator extends React.Component {
  constructor(props) {
    super(props);
    this.ddp = props.ddp;
  }

  _leftButton(route, navigator, index, navState) {
    if (route.id) {
      return (
        <TouchableOpacity
          onPress={() => navigator.pop()}
          style={styles.navBarLeftButton}>
          <Text style={[styles.navBarText, styles.navBarButtonText, SHEET.baseText]}>
            Back
          </Text>
        </TouchableOpacity>
      );
    }
  }

  _rightButton(route, navigator, index, navState) {
    return null;
  }

  _title (route, navigator, index, navState) {
    return (
      <Text style={[styles.navBarText, styles.navBarTitleText, SHEET.baseText]}>
        {route.title}
      </Text>
    );
  }

  _onNavigationStateChange(nav, navState) {
    if (navState.url.indexOf('taylr-dev://') != -1) {
      return nav.pop();
    }
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
          <Discover navigator={nav} ddp={this.ddp} 
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
        configureScene={(route) =>
          Navigator.SceneConfigs.HorizontalSwipeJump}
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

module.exports = DiscoverNavigator;