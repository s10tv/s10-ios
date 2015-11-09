let React = require('react-native');
let {
  AppRegistry,
  View,
  Text,
  Navigator,
  StyleSheet,
} = React;

let HashtagCategory = require('./HashtagCategory');
let Hashtag = require('./Hashtag');

class LayoutContainer extends React.Component {

  renderScene(route, nav) {
    switch (route.id) {
      case 'hashtag':
        return <Hashtag navigator={nav} category={route.category} />;
      default:
        return (
          <HashtagCategory
            title='My Hashtags'
            navigator={nav} />
        );
    }
  }

  render() {
    return (
      <Navigator
        itemWrapperStyle={styles.navWrap}
        style={styles.nav}
        renderScene={this.renderScene}
        initialRoute={{
          title: 'My Hashtags',
          component: HashtagCategory,
          passProps: {
            toggleNavBar: this.toggleNavBar,
          }
        }
      } />
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