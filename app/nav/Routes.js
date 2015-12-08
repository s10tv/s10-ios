import React, {
  Text,
  TouchableOpacity,
} from 'react-native';

import ExNavigator from '@exponent/react-native-navigator'

import { SHEET } from '../CommonStyles'

const logger = new (require('../../modules/Logger'))('Routes');

class Router {

  static instance = null;

  constructor(props = {}) {
    logger.debug(`created a new Router ${JSON.stringify(props)}`);
    logger.debug(`created a new Router ${props.onPressLogout === undefined}`);
    this.props = props;
  }

  getButton(text, action, type = { isLeft: true }) {
    return (
      <TouchableOpacity
        style={type.isLeft ? SHEET.navBarLeftButton : SHEET.navBarRightButton}
        onPress={action}>
          <Text style={[SHEET.navBarText, SHEET.navBarButtonText, SHEET.baseText]}>{text}</Text>
      </TouchableOpacity>
    )
  }

  getMainNavigatorRoute(currentScreen) {
    const self = this;
    return {
      renderScene(navigator) {
        return (
          <ExNavigator
            navigator={navigator}
            titleStyle={[SHEET.navBarTitleText, SHEET.baseText]}
            barButtonTextStyle={[SHEET.navBarText, SHEET.navBarButtonText, SHEET.baseText]}
            barButtonIconStyle={{ tintColor: 'white' }}
            initialRoute={self.getTabScreenRoute(currentScreen)}
            style={{ flex: 1 }}
            navigationBarStyle={{ flex: 1, backgroundColor: '#64369C' }}
            sceneStyle={{ paddingTop: 64 }}
          />
        )
      },
    };
  }

  _getTabScreenTitle() {
    switch (this.currentScreen.id) {
      case 'SCREEN_TODAY':
        return 'Today';
      case 'SCREEN_ME':
        return 'Me';
      case 'SCREEN_CONVERSATION_LIST':
        return 'Conversations';

      default:
        return null
    }
  }

  getTabScreenRoute(currentScreen) {
    const self = this;
    return {
      renderScene(navigator) {
        let TabNavigatorScreen = require('./TabNavigatorScreen');
        return <TabNavigatorScreen
          navigator={navigator}
          onPressLogout={self.props.onPressLogout}
          onViewProfile={self.props.onViewProfile}
          onEditProfile={self.props.onEditProfile}
        />
      },

      getTitle() {
        return self._getTabScreenTitle();
      },

      renderRightButton(navigator) {
        if (self.currentScreen.id == 'SCREEN_TODAY') {
          return self.getButton('History', () => {
            const route = self.getHistoryRoute();
            navigator.push(route)
          }, { isLeft: false })
        }
      },
    }
  }

  getLoginRoute() {
    const self = this;
    return {
      renderScene(navigator) {
        let LoginScreen = require('../components/onboarding/LoginScreen');
        return <LoginScreen
          navigator={navigator}
          onPressLogin={self.props.onPressLogin} />;
      },
    }
  }

  getHistoryRoute() {
    const self = this;
    return {
      renderScene(navigator) {
        let HistoryScreen = require('../components/history/HistoryScreen');
        return <HistoryScreen navigator={navigator} />
      },

      getTitle() {
        return 'History';
      },
    }
  }

  getProfileRoute(userId) {
    const self = this;
    return {
      renderScene(navigator) {
        return (
          <ExNavigator
            navigator={navigator}
            initialRoute={self.__getProfileScreen(userId)}
            navigationBarStyle={{ flex: 1, backgroundColor: 'transparent' }}
          />
        )
      },
    }
  }

  __getProfileScreen(userId) {
    const self = this;
    return {
      renderScene(navigator) {
        let ProfileScreen = require('../components/profile/ProfileScreen');
        return <ProfileScreen
          navigator={navigator}
          userId={userId}
        />
      },

      renderLeftButton(navigator) {
        return self.getButton('Back', () => { navigator.parentNavigator.pop() })
      },
    }
  }

  getEditProfileRoute() {
    const self = this;
    return {
      renderScene(navigator) {
        let EditProfileScreen = require('../components/editprofile/EditProfileScreen');
        return <EditProfileScreen
          onUploadImage={self.props.onUploadImage}
          onLinkFacebook={self.props.onLinkFacebook}
          onEditProfileChange={self.props.onEditProfileChange}
          onEditProfileFocus={self.props.onEditProfileFocus}
          onEditProfileBlur={self.props.onEditProfileBlur}
          updateProfile={self.props.updateProfile}
          navigator={navigator} />
      },
    }
  }

  getLinkViaWebView(serviceName, url) {
    const self = this;
    return {
      renderScene(navigator) {
        let LinkServiceScreen = require('../components/linkservice/LinkServiceScreen');
        return <LinkServiceScreen
          navigator={navigator}
          url={url}
        />
      },

      getTitle() {
        return `Link ${serviceName}`
      },
    }

  }

  getConverstionRoute(conversationId) {
    const self = this;
    return {
      renderScene(navigator) {
        let ConversationScreen = require('../components/chat/ConversationScreen');
        return <ConversationScreen
          navigator={navigator}
          conversationId={conversationId}
        />
      },
    }
  }
}

export default Router;
