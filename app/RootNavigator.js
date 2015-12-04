import React, {
  Navigator,
  TouchableOpacity,
  Text,
  StyleSheet,
} from 'react-native';

// external dependencies
import { connect } from 'react-redux/native';
import TabNavigatorScreen from './components/TabNavigatorScreen';
import Router from './Router';

import { SWITCH_BASE_TAB } from './constants'

function mapStateToProps(state) {
  return {
    routes: state.routes.root
  }
}

class RootNavigator extends React.Component {

  leftButton(route, navigator, index, navState) {
    if (this.props.nav.left.show) {
      return (
        <TouchableOpacity
          onPress={() => navigator.pop() }
        >
          <Text>
            Back
          </Text>
        </TouchableOpacity>
      );
    }

    return null;
  }

  rightButton(route, navigator, index, navState) {
    let rightNav = this.props.nav.right;
    if (rightNav.show) {
      return (
        <TouchableOpacity
          onPress={rightNav.onClick}
        >
          <Text>
            {rightNav.text}
          </Text>
        </TouchableOpacity>
      );
    }
  }

  title() {
    // TODO(qimingfang)
    return null;
  }

  renderScene(route, nav) {
    this.router = this.router || new Router(nav, this.props.dispatch);

    if (route.component) {
      return React.createElement(route.component, route.props)
    }

    const props = Object.assign({}, route.props, this.props, {
      navigator: nav,
    });

    return <TabNavigatorScreen {...props} />
  }

  render() {
    return (
      <Navigator
        ref='nav'
        itemWrapperStyle={styles.nav}
        style={styles.nav}
        renderScene={this.renderScene.bind(this)}
        configureScene={(route) => ({
          ...Navigator.SceneConfigs.HorizontalSwipeJump,
          gestures: {}, // or null
        })}
        initialRoute={{
          id: 'not-used'
        }}
        navigationBar={
          <Navigator.NavigationBar
            routeMapper={{
              LeftButton: this.leftButton.bind(this),
              RightButton: this.rightButton.bind(this),
              Title: this.title.bind(this)
            }}
            style={styles.navBar}
          />
        }>
      </Navigator>
    )
  }
}


let styles = StyleSheet.create({
  nav: {
    flex: 1,
  },
  navBar: {
    backgroundColor: '#64369C',
  },
});

export default connect(mapStateToProps)(RootNavigator)
