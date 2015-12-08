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

  getMainNavigatorRoute() {
    const self = this;
    return {
      renderScene(navigator) {
        return (
          <ExNavigator
            navigator={navigator}
            titleStyle={[SHEET.navBarTitleText, SHEET.baseText]}
            barButtonTextStyle={[SHEET.navBarText, SHEET.navBarButtonText, SHEET.baseText]}
            barButtonIconStyle={{ tintColor: 'white' }}
            initialRoute={self.getTabScreenRoute()}
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

  getTabScreenRoute() {
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
          onPressLogout={self.props.onPressLogout}
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

  getProfileRoute({ userId, isFromDiscoveryScreen = false, isFromHistoryScreen = false }) {
    const self = this;
    return {
      renderScene(navigator) {
        return (
          <ExNavigator
            navigator={navigator}
            initialRoute={self.__getProfileScreen(
              userId, isFromDiscoveryScreen, isFromHistoryScreen)}
            navigationBarStyle={{ flex: 1, backgroundColor: 'transparent' }}
          />
        )
      },
    }
  }

  __getProfileScreen(userId, isFromDiscoveryScreen = false, isFromHistoryScreen = false) {
    const self = this;
    return {
      renderScene(navigator) {
        let ProfileScreen = require('../components/profile/ProfileScreen');
        return <ProfileScreen
          navigator={navigator}
          isFromDiscoveryScreen={isFromDiscoveryScreen}
          isFromHistoryScreen={isFromHistoryScreen}
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

      renderLeftButton(navigator) {
        return self.getButton('Back', () => {
          self.__saveProfileIfCurrentlyInEditMode()
          navigator.pop()
        })
      }
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

  getSendMessageToUserRoute(recipientUser) {
    const self = this;
    return {
      renderScene(navigator) {
        let ConversationScreen = require('../components/chat/ConversationScreen');
        return <ConversationScreen
          navigator={navigator}
          recipientUser={recipientUser}
        />
      },
    }
  }

  getTagListRoute(category) {
    const self = this;
    return {
      renderScene(navigator) {
        let TagListScreen= require('../components/taglist/TagListScreen');
        return <TagListScreen
          navigator={navigator}
          category={category}
        />
      },
    }
  }

  // Onboarding
  getOnboardingRoute() {
    const self = this;
    return {
      renderScene(navigator) {
        return (
          <ExNavigator
            navigator={navigator}
            titleStyle={[SHEET.navBarTitleText, SHEET.baseText]}
            barButtonTextStyle={[SHEET.navBarText, SHEET.navBarButtonText, SHEET.baseText]}
            barButtonIconStyle={{ tintColor: 'white' }}
            initialRoute={self.getJoinNetworkRoute()}
            navigationBarStyle={{ flex: 1, backgroundColor: '#64369C' }}
            sceneStyle={{ paddingTop: 64 }}
          />
        )
      },
    }
  }

  getJoinNetworkRoute() {
    const self = this;
    return {
      renderScene(navigator) {
        let JoinNetworkScreen = require('../components/onboarding/JoinNetworkScreen');
        return <JoinNetworkScreen
          navigator={navigator}
        />
      },

      getTitle() {
        return 'Join Network'
      },

      renderLeftButton(navigator) {
        return self.getButton('Back', () => {
          navigator.parentNavigator.pop()
        });
      },
    }
  }

  getUBCCWLRoute() {
    const self = this;
    const CampusWideLoginScreen = require('../components/onboarding/CampusWideLoginScreen');

    return {
      renderScene(navigator) {
        return <CampusWideLoginScreen
          navigator={navigator}
        />
      },

      getTitle() {
        return 'CWL'
      },
    }
  }

  getLinkServiceRoute() {
    const self = this;
    return {
      renderScene(navigator) {
        let LinkServiceScreen = require('../components/onboarding/LinkServiceScreen');
        return <LinkServiceScreen
          onLinkFacebook={self.props.onLinkFacebook}
          navigator={navigator}
        />
      },

      renderRightButton(navigator) {
        // TODO(qimingfang): double check.
        return self.getButton('Next', () => {
          navigator.push(self.getCreateProfileScreen());
        }, { isLeft: false })
      }
    }
  }

  getCreateProfileScreen() {
    const self = this;
    return {
      renderScene(navigator) {
        let CreateProfileScreen = require('../components/onboarding/CreateProfileScreen');
        return <CreateProfileScreen
          onUploadImage={self.props.onUploadImage}
          onLinkFacebook={self.props.onLinkFacebook}
          onEditProfileChange={self.props.onEditProfileChange}
          onEditProfileFocus={self.props.onEditProfileFocus}
          onEditProfileBlur={self.props.onEditProfileBlur}
          updateProfile={self.props.updateProfile}
          navigator={navigator}
        />
      },

      renderRightButton(navigator) {
        // TODO(qimingfang): double check.
        return self.getButton('Next', () => {
          navigator.push(self.getAddTagScreen());
        }, { isLeft: false })
      }
    }
  }

  getAddTagScreen() {
    const self = this;
    return {
      renderScene(navigator) {
        let AddTagScreen = require('../components/onboarding/AddTagScreen');
        return <AddTagScreen
          navigator={navigator}
        />
      },

      renderRightButton(navigator) {
        // TODO(qimingfang): DDP call, set isActive.
        return self.getButton('Done', () => {
          navigator.parentNavigator.push(self.getMainNavigatorRoute());
        }, { isLeft: false })
      }
    }
  }

  __saveProfileIfCurrentlyInEditMode() {
    if (this.editProfileFocused) {
      this.editProfileFocused = false;
      this.props.updateProfile(this.editProfileKey, this.currentlyEditing)
    }
  }
}

export default Router;
