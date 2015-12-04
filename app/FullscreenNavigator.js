import React, {
  Navigator,
  TouchableOpacity,
  Text,
  NativeAppEventEmitter,
  StyleSheet,
} from 'react-native';

// external dependencies
import { connect } from 'react-redux/native'

import TSNavigationBar from './components/lib/TSNavigationBar';
import Router from './Router';
import RootNavigator from './RootNavigator';
import { COLORS, SHEET } from './CommonStyles'

const logger = new (require('../modules/Logger'))('FullScreenNavigator');

function mapStateToProps(state) {
  logger.debug(`state.routes: ${JSON.stringify(state.routes)}`);
  return {
    nav: state.routes.fullscreen.nav,
    displayTitle: state.routes.fullscreen.nav.displayTitle
  }
}

class FullScreenNavigator extends React.Component {

  leftButton(route, navigator, index, navState) {
    if (this.props.nav.left.show) {
      return (
        <TouchableOpacity
          onPress={() => this.router.pop() }
          style={SHEET.navBarLeftButton}>
          <Text style={[SHEET.navBarText, SHEET.navBarButtonText, SHEET.baseText]}>
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

  title(route) {
    logger.debug(`route: ${route.id}`)
    logger.debug(`rendering title title=${this.props.displayTitle}`)
    if (this.props.displayTitle) {
      return (
        <Text style={[styles.navBarTitleText, SHEET.baseText]}>
          { this.props.displayTitle }
        </Text>
      );
    }
  }

  componentDidMount() {
    this.navigateToConversationViewListener = NativeAppEventEmitter
      .addListener('Navigation.push', (properties) => {
        logger.debug('did receive Navigation.push')
        switch (properties.routeId) {
          case 'conversation':
            return this.router.toConversation({
              conversationId: properties.args.conversationId
            })

          case 'profile':
            return this.router.toProfile({
              userId: properties.args.userId
            })
        }
    });

    this.popListener = NativeAppEventEmitter
      .addListener('Navigation.pop', (properties) => {
        logger.debug('did receive Navigation.pop')
        this.router.pop();
      });
  }

  renderScene(route, nav) {
    this.router = this.router || new Router(nav, this.props.dispatch)

    if (route.component) {
      return React.createElement(route.component, route.props)
    }

    const props = Object.assign({}, route.props, this.props, {
      navigator: nav,
    });

    return <RootNavigator {...props} />
  }

  render() {
    logger.debug(`rendering full screen nav. hidden=${JSON.stringify(this.props.nav.hidden)}`);

    return (
      <Navigator
        ref='nav'
        style={styles.nav}
        itemWrapperStyle={styles.nav}
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
            hidden={this.props.nav.hidden.present}
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

let styles = StyleSheet.create({
  nav: {
    flex: 1,
  },
  navBarTitleText: {
    fontSize: 20,
    color:  'black',
    fontWeight: '500',
    marginVertical: 9,
  },
  selected: {
    tintColor: '#64369C',
  },
  selectedText: {
    color: '#64369C',
  }
});

export default connect(mapStateToProps)(FullScreenNavigator)
