import React, {
  Navigator,
  TouchableOpacity,
  Text
} from 'react-native';

// external dependencies
import { connect } from 'react-redux/native';

function mapStateToProps(state) {
  return {
    routes: {
      onboarding: state.routes.onboarding
    }
  }
}

class OnboardingNavigator extends React.Component {

  leftButton(route, navigator, index, navState) {
    if (this.props.routes.onboarding.nav.left.show) {
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
    const currentScreen = this.props.routes.onboarding.currentScreen;
    const props = Object.assign({}, route.props, this.props, {
      navigator: nav,
    });
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

export default connect(mapStateToProps)(OnboardingNavigator);
