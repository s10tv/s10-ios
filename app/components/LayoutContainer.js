let React = require('react-native');
let {
  AppRegistry,
  View,
  Text,
  TouchableOpacity,
  Navigator,
  WebView,
  StyleSheet,
} = React;

let Me = require('./Me');
let MeEdit = require('./MeEdit');
let HashtagCategory = require('./HashtagCategory');
let Hashtag = require('./Hashtag');

var NavigationBarRouteMapper = {
  LeftButton: function(route, navigator, index, navState) {
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
  },

  RightButton: function(route, navigator, index, navState) {
  },

  Title: function(route, navigator, index, navState) {
    return (
      <Text style={[styles.navBarText, styles.navBarTitleText]}>
        {route.title}
      </Text>
    );
  },

};

class LayoutContainer extends React.Component {

  renderScene(route, nav) {
    switch (route.id) {
      case 'hashtag':
        return <Hashtag navigator={nav} category={route.category} />;
      case 'servicelink':
        return <WebView
          style={styles.webView}
          startInLoadingState={true}
          url={route.link} />;
      default:
        return (
          <MeEdit navigator={nav} />
        );
    }
  }

  render() {
    return (
      <Navigator
        itemWrapperStyle={styles.navWrap}
        style={styles.nav}
        renderScene={this.renderScene}
        configureScene={(route) => Navigator.SceneConfigs.FloatFromRight}
        initialRoute={{
          title: 'Me',
        }}
        navigationBar={
          <Navigator.NavigationBar
            routeMapper={NavigationBarRouteMapper}
            style={styles.navBar} />
        } />
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
    paddingRight: 10,
  },
});

module.exports = LayoutContainer;