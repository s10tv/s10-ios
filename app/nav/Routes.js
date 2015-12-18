import React, {
  Text,
  TouchableOpacity,
} from 'react-native';

import ExNavigator from '@exponent/react-native-navigator';

import { SHEET } from '../CommonStyles';
import Analytics from '../../modules/Analytics';

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
      case 'SCREEN_EVENTS':
        return 'Events';

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
          upgrade={self.props.upgrade}
          onFetchCourses={self.props.onFetchCourses}
          onRemoveCourse={self.props.onRemoveCourse}
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

  getProfileRoute({
      user,
      userId,
      additionalProps = {},
      isEditable = false,
      isFromMeScreen = false,
      isFromDiscoveryScreen = false,
      isFromHistoryScreen = false,
      isFromMeScreen = false,
      isFromConversationScreen = false,
      isFromCoursesView = false,
  }) {
    const self = this;

    if (isEditable) {
      return Object.assign({}, self.__getProfileScreen(
        user,
        userId,
        additionalProps,
        isFromMeScreen,
        isEditable), {
          getTitle() {
           return 'Profile'
          },

          renderRightButton(navigator) {
            // TODO(qimingfang): DDP call, set isActive.
            return self.getButton('Done', () => {
              self.props.ddp.call({ methodName: 'confirmRegistration' })
              .then(() => {
                navigator.parentNavigator.push(self.getMainNavigatorRoute());
              })
              .catch(err => {
                self.props.dispatch({
                  type: 'DISPLAY_ERROR',
                  title: 'One small issue ...',
                  message: err.reason,
                })
              })
            }, { isLeft: false })
          }
        });
    }

    return {
      renderScene(navigator) {
        return (
          <ExNavigator
            navigator={navigator}
            barButtonIconStyle={{ tintColor: '#ffffff' }}
            initialRoute={self.__getProfileScreen(
              user,
              userId,
              additionalProps,
              isFromMeScreen,
              isEditable,
              isFromDiscoveryScreen,
              isFromHistoryScreen,
              isFromMeScreen,
              isFromConversationScreen,
              isFromCoursesView)
            }
            navigationBarStyle={{
              flex: 1, backgroundColor: 'transparent',
              borderBottomColor: 'transparent', borderBottomWidth: 0, }}
          />
        )
      },
    }
  }

  __getProfileScreen(
      user,
      userId,
      additionalProps = {},
      isFromMeScreen = false,
      isEditable = false,
      isFromDiscoveryScreen = false,
      isFromHistoryScreen = false,
      isFromConversationScreen = false,
      isFromCoursesView = false) {
    const self = this;
    return {
      renderScene(navigator) {
        let ProfileScreen = require('../components/profile/ProfileScreen');
        return <ProfileScreen
          navigator={navigator}
          isEditable={isEditable}
          isFromDiscoveryScreen={isFromDiscoveryScreen}
          isFromHistoryScreen={isFromHistoryScreen}
          isFromCoursesView={isFromCoursesView}
          isFromMeScreen={isFromMeScreen}
          onUploadImage={self.props.onUploadImage}
          userId={userId}
          user={user}
          {...additionalProps}
        />
      },

      renderLeftButton(navigator) {
        return self.getButton('Back', () => { navigator.parentNavigator.pop() })
      },

      renderRightButton() {
        if (isFromHistoryScreen || isFromDiscoveryScreen || isFromConversationScreen) {
          return self.getButton('Report', () => {
            return self.props.reportUser(userId)
          }, { isLeft: false })
        }
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

  getCourseDetailRoute({course, renderWithNewNav = false}) {
    const self = this;
    if (renderWithNewNav) {
      return {
        renderScene(navigator) {
          return (
            <ExNavigator
              navigator={navigator}
              titleStyle={[SHEET.navBarTitleText, SHEET.baseText]}
              barButtonTextStyle={[SHEET.navBarText, SHEET.navBarButtonText, SHEET.baseText]}
              barButtonIconStyle={{ tintColor: '#ffffff' }}
              initialRoute={self.__getCourseDetailRoute(course)}
              navigationBarStyle={{ flex: 1, backgroundColor: '#64369C' }}
              sceneStyle={{ paddingTop: 64 }}
            />
          )
        }
      }
    } else {
      return self.__getCourseDetailRoute(course);
    }
  }

  __getCourseDetailRoute(course) {
    const self = this;
    return {
      renderScene(navigator) {
        let CourseDetailsScreen = require('../components/courses/CourseDetailsScreen');
        return <CourseDetailsScreen
          navigator={navigator}
          courseCode={course.courseCode}
        />
      },

      getTitle() {
        return `${course.dept} ${course.course}`
      },
    }
  }

  getMyCoursesListRoute() {
    const self = this;
    return {
      renderScene(navigator) {
        let MyCoursesScreen = require('../components/courses/MyCoursesScreen').MyCoursesScreen;
        return <MyCoursesScreen
          navigator={navigator}
          onRemoveCourse={self.props.onRemoveCourse}
        />
      },

      getTitle() {
        return 'Courses'
      },
    }
  }

  getAllCoursesListRoute() {
    return {
      renderScene(navigator) {
        let AddNewCourseScreen = require('../components/courses/AddNewCourseScreen');
        return <AddNewCourseScreen
          navigator={navigator}
        />
      },

      getTitle() {
        return 'Add Course'
      }
    }
  }

  // Events
  getSpeedIntrosRoute(event) {
    const self = this;
    return {
      renderScene(navigator) {
        let SpeedIntros = require('../components/events/games/SpeedIntros');
        return <SpeedIntros navigator={navigator} eventId={event._id} />;
      },
    }
  }

  getEventDetailScreen(event) {
    const self = this;
    return {
      renderScene(navigator) {
        let EventDetailScreen = require('../components/events/EventDetailScreen');
        return <EventDetailScreen navigator={navigator} event={event} />;
      },

      getTitle() {
        return event.title
      }
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
        return 'CWL'
      },

      renderLeftButton(navigator) {
        return self.getButton('Back', () => {
          navigator.parentNavigator.pop()
        });
      },
    }
  }

  getReloginForCourseFetchRoute() {
    const self = this;
    const CampusWideLoginScreen = require('../components/onboarding/CampusWideLoginScreen');

    return {
      renderScene(navigator) {
        return <CampusWideLoginScreen
          navigator={navigator}
          clearCookies={true}
          onFinishedCWL={() => {
            navigator.pop()
            return self.props.onFetchCourses() // if there is an error, it will pop up error.
          }}
        />
      },

      getTitle() {
        return 'UBC'
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
          clearCookies={true}
          onFinishedCWL={() => {
            // if there is an error, it will pop up error.
            self.props.onFetchCourses({ showCompletionAlert: false });

            const route = self.getProfileRoute({
              userId: self.props.ddp.currentUserId,
              isEditable: true });
            navigator.push(route);
          }}
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
      }
    }
  }

  getWebviewLinkRoute(title, url) {
    const self = this;

    const route = {
      renderScene(navigator) {
        let LinkServiceScreen = require('../components/linkservice/LinkServiceScreen');
        return <LinkServiceScreen
          navigator={navigator}
          url={url}
        />
      },

      getTitle() {
        return title;
      },

      renderLeftButton(navigator) {
        return self.getButton('Back', () => {
          return navigator.parentNavigator.pop()
        })
      }
    };

    return {
      renderScene(navigator) {
        return (
          <ExNavigator
            titleStyle={[SHEET.navBarTitleText, SHEET.baseText]}
            barButtonTextStyle={[SHEET.navBarText, SHEET.navBarButtonText, SHEET.baseText]}
            barButtonIconStyle={{ tintColor: 'white' }}
            navigator={navigator}
            initialRoute={route}
            navigationBarStyle={{ flex: 1, backgroundColor: '#64369C' }}
            sceneStyle={{ paddingTop: 64 }}
          />
        )
      },
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
