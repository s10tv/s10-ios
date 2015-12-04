let React = require('react-native');

let {
  AppRegistry,
  Navigator,
} = React;
let _ = require('lodash')

class TSNavigationBar extends Navigator.NavigationBar {

  render() {
    if (this.props.hidden) {
      return null;
    }
    
    return super.render();
  }
}

module.exports = TSNavigationBar;
