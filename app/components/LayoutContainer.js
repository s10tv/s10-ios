let React = require('react-native');
let {
  AppRegistry,
  View,
  Text,
  NavigatorIOS,
  StyleSheet,
} = React;

let HashtagCategory = require('./HashtagCategory');

class LayoutContainer extends React.Component {

  render() {
    return (
      <NavigatorIOS ref="nav"
        itemWrapperStyle={styles.navWrap}
        style={styles.nav}
        initialRoute={{
          title: 'My Hashtags',
          component: HashtagCategory,
          passProps: {
            toggleNavBar: this.toggleNavBar,
          }
        }} />
    )
  }
}

var styles = StyleSheet.create({
  navWrap: {
    flex: 1,
    marginTop: 15
  },
  nav: {
    flex: 1,
  },
});

module.exports = LayoutContainer;