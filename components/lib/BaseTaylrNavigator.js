let React = require('react-native');

let {
  AppRegistry,
  Navigator,
  Text,
  StyleSheet,
} = React;

class BaseTaylrNavigator extends React.Component {

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
}