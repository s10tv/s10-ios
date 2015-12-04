import React, {
  Navigator,
  TouchableOpacity,
  Text,
} from 'react-native';

// external dependencies
import { connect } from 'react-redux/native'

function mapStateToProps(state) {
  return {
    routes: state.routes
  }
}

class RootNavigator extends React.Component {

  leftButton(route, navigator, index, navState) {
    if (this.props.routes.root.nav.left.show) {
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
    const currentScreen = this.props.routes.root.currentScreen;
    return React.createElement(currentScreen, Object.assign({}, route.props, {
        navigator: nav,
    }))
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
          id: this.props.routes.root,
        }}
        navigationBar={
          <Navigator.NavigationBar
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

export default connect(mapStateToProps)(RootNavigator)
