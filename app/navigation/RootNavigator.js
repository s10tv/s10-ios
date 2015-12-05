import React, {
  Navigator,
  TouchableOpacity,
  StyleSheet,
} from 'react-native';

// external dependencies
import { connect } from 'react-redux/native';

// internal depdencies
import DiscoverScreen from '../components/discover/DiscoverScreen';
import TabNavigatorScreen from './TabNavigatorScreen';
import RootRouter from './RootRouter';

import { TAB_SCREEN_CONTAINER } from '../constants'

const logger = new (require('../../modules/Logger'))('RootNavigator');

function mapStateToProps(state) {
  return {
    currentScreen: state.currentScreen,
    routes: state.routes.root,
  }
}

class RootNavigator extends React.Component {

  leftButton(route, nav, index, navState) {
    this.router = this.router || new RootRouter(nav, this.props.dispatch);
    return this.router.leftButton(route);
  }

  rightButton(route, nav, index, navState) {
    this.router = this.router || new RootRouter(nav, this.props.dispatch);
    return this.router.rightButton(route);
  }

  title(route, nav) {
    return this.router.title(this.props.currentScreen.present);
  }

  renderScene(route, nav) {
    this.router = this.router || new RootRouter(nav, this.props.dispatch);

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
