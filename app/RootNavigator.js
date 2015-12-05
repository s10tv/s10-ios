import React, {
  Navigator,
  TouchableOpacity,
  Text,
  StyleSheet,
} from 'react-native';

// external dependencies
import { connect } from 'react-redux/native';
import TabNavigatorScreen from './components/TabNavigatorScreen';
import DiscoverScreen from './components/discover/DiscoverScreen';
import Router from './RootRouter';

import { TAB_SCREEN_CONTAINER } from './constants'

function mapStateToProps(state) {
  return {
    currentScreen: state.currentScreen,
    routes: state.routes.root,
  }
}

class RootNavigator extends React.Component {

  leftButton(route, nav, index, navState) {
    this.router = this.router || new Router(nav, this.props.dispatch);
    return Router.leftButton(route, this.router);
  }

  rightButton(route, nav, index, navState) {
    this.router = this.router || new Router(nav, this.props.dispatch);
    return Router.rightButton(route, this.router);
  }

  title(route, nav) {
    return Router.title(this.props.currentScreen.present);
  }

  renderScene(route, nav) {
    this.router = this.router || new Router(nav, this.props.dispatch);

    if (this.router.canHandleRoute(route)) {
      return this.router.handle(route);
    }

    return <TabNavigatorScreen {...route.props} />
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
          id: this.props.currentScreen.id,
          props: this.props,
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
