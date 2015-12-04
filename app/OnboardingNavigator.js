import {
  Navigator,
} from require('react-native');

class OnboardinNavigator extends React.Component {

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
          <NavigationBar
            routeMapper={{
              LeftButton: this._leftButton.bind(this),
              RightButton: this._rightButton.bind(this),
              Title: this._title.bind(this)
            }}
          />
        }>
      </Navigator>
    )
  }
}

module.exports = OnboardinNavigator;
