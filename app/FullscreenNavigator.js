import React, {
  Navigator,
  TouchableOpacity,
  Text,
} from 'react-native';

// external dependencies
import { connect } from 'react-redux/native'

import TSNavigationBar from './components/lib/TSNavigationBar';

function mapStateToProps(state) {
  return {
    routes: {
      fullscreen: state.routes.fullscreen
    }
  }
}

class FullScreenNavigator extends React.Component {

  leftButton(route, navigator, index, navState) {
    if (this.props.routes.fullscreen.nav.left.show) {
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
    // TODO(qimingfang)
    return null;
  }

  title() {
    // TODO(qimingfang)
    return null;
  }

  renderScene(route, nav) {
    if (this.props.routes.fullscreen.didPressBack) {
      nav.pop();
      return;
    }

    const currentScreen = this.props.routes.fullscreen.currentScreen;
    const currentProps = this.props.routes.fullscreen.currentProps;
    const props = Object.assign({}, route.props, this.props, currentProps, {
      navigator: nav,
    });

    if (this.props.routes.fullscreen.didPressNext) {
      nav.push({
        id: this.props.routes.fullscreen.nextRouteId
        component: this.props.routes.fullscreen.currentScreen,
        props: props,
      })
      return;
    }

    if (route.component) {
      return React.createElement(route.component, route.props)
    }

    return React.createElement(currentScreen, props)
  }

  render() {
    return (
      <Navigator
        ref='nav'
        renderScene={this.renderScene.bind(this)}
        configureScene={(route) => ({
          ...Navigator.SceneConfigs.HorizontalSwipeJump,
          gestures: {}, // or null
        })}
        initialRoute={{
          id: 'not-used'
        }}
        navigationBar={
          <TSNavigationBar
            hidden={this.props.routes.fullscreen.nav.hidden}
            routeMapper={{
              LeftButton: this.leftButton.bind(this),
              RightButton: this.rightButton.bind(this),
              Title: this.title.bind(this)
            }}
          />
        }>
      </Navigator>
    )
  }
}

export default connect(mapStateToProps)(FullScreenNavigator)
