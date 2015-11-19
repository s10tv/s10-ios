let React = require('react-native');

let {
  AppRegistry,
  Navigator,
} = React;
let _ = require('lodash')

class TSNavigationBar extends Navigator.NavigationBar {

  render() {
    let omitRoutes = this.props.omitRoutes || [];
    let routes = this.props.navState.routeStack;

    console.log(_.keys(this.props));

    if (routes.length) {
      var route = routes[routes.length - 1];

      if (route.id && omitRoutes.indexOf(route.id) >= 0) {
        return null;
      }
    }

    return super.render();
  }
}

module.exports = TSNavigationBar;