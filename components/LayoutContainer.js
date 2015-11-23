let React = require('react-native');

let {
  AppRegistry,
  AsyncStorage,
  NativeAppEventEmitter,
  View,
  TabBarIOS,
} = React;

let OnboardingNavigator = require('./onboarding/OnboardingNavigator');
let RootNavigator = require('./RootNavigator');
let Loader = require('./lib/Loader');

let TSDDPClient = require('../lib/ddpclient');
let TSLayerService = React.NativeModules.TSLayerService;

let SHEET = require('./CommonStyles').SHEET;

class LayoutContainer extends React.Component {

  constructor(props: {}) {
    super(props);
    this.ddp = new TSDDPClient(props.wsurl);

    this.subs = {}

    this.state = {
      needsOnboarding: true,
      modalVisible: false,
      currentTab: 'chats',
    }
  }

  onLogout() {
    TSLayerService.deauthenticate((err, res) => {
      this.setState({ loggedIn: false });
    })
  }

  onLogin(options) {
    let { token, userId, tokenExpires } = options;

    if (!token) {
      console.error('OnLogin called with invalid Token');
    }

    this.setState({ loggedIn: true });

    let multiSetValues = [
      ['userId', userId],
      ['loginToken', token],
    ];

    AsyncStorage.multiSet(multiSetValues)
    .then(() => {
      let ddp = this.ddp;

      this.__layerLogin()

      this.ddp.subscribe({ pubName: 'settings' })
      .then(() => {
        ddp.collections.observe(() => {
          if (ddp.collections.settings) {
            return ddp.collections.settings.find({});
          }
        }).subscribe(settings => {
          indexedSettings =  {};
          settings.forEach((setting) => {
            indexedSettings[setting._id] = setting;
          });

          this.setState({ settings: indexedSettings });

          if (indexedSettings.accountStatus) {
            this.setState ({
              isActive: indexedSettings.accountStatus.value == 'active'
            })
          }
        });
      });

      this.ddp.subscribe({ pubName: 'me' })
      .then(() => {
        ddp.collections.observe(() => {
          if (ddp.collections.users) {
            return ddp.collections.users.findOne({ _id: ddp.currentUserId });
          }
        }).subscribe(currentUser => {
          this.setState({ me: currentUser });
        });

        ddp.collections.observe(() => {
          if (ddp.collections.users) {
            return ddp.collections.users.find({});
          }
        }).subscribe(users => {
          this.setState({ users: users });
        });
      });

      this.ddp.subscribe({ pubName: 'integrations' })
      .then(() => {
        ddp.collections.observe(() => {
          if (ddp.collections.integrations) {
            return ddp.collections.integrations.find({});
          }
        }).subscribe(integrations=> {
          integrations.sort((one, two) => {
            return one.status == 'linked' ? -1 : 1;
          })
          this.setState({ integrations: integrations });
        });
      });

      this.ddp.subscribe({ pubName: 'hashtag-categories' })
      .then(() => {
        ddp.collections.observe(() => {
          if (ddp.collections.categories) {
            return ddp.collections.categories.find({});
          }
        }).subscribe(categories=> {
          this.setState({ categories: categories });
        });
      });

      this.ddp.subscribe({ pubName: 'my-tags' })
      .then(() => {
        ddp.collections.observe(() => {
          if (ddp.collections.mytags) {
            return ddp.collections.mytags.findOne({});
          }
        }).subscribe(user => {
          if (user && user.tags) {
            user.tags.forEach((tag) => {
              tag.isMine = true;
            })
            this.setState({ myTags: user.tags });
          }
        });
      });

      this.ddp.subscribe({ pubName: 'candidate-discover' })
      .then(() => {
        ddp.collections.observe(() => {
          if (ddp.collections.candidates) {
            return ddp.collections.candidates.find({});
          }
        }).subscribe(candidates => {
          let activeCandidates = candidates.filter((candidate) => {
            return candidate.type == 'active'
          })

          let historyCandidates = candidates.filter((candidate) => {
            return candidate.type == 'expired'
          })

          if (activeCandidates.length > 0) {
            this.setState({ candidate: activeCandidates[0] })
          }

          this.setState({ history: historyCandidates });
        });
      });

      this.ddp.subscribe({ pubName: 'activities', params:[ddp.currentUserId] })
      .then(() => {
        ddp.collections.observe(() => {
          if (ddp.collections.activities) {
            return ddp.collections.activities.find({ userId: ddp.currentUserId });
          }
        }).subscribe(activities => {
          this.setState({ myActivities: activities });
        });
      });
    })
  }

  __layerLogin() {
    NativeAppEventEmitter.addListener('Layer.allConversationsCountUpdate', (count) => {
      this.setState({ numTotalConversations: count })
    }.bind(this))

    TSLayerService.connectAsync().then(() => {
      return TSLayerService.isAuthenticatedAsync();
    }).then(isAuthenticated => {
      if (isAuthenticated) { 
        return Promise.resolve(true);
      } else {
        return TSLayerService.requestAuthenticationNonceAsync().then(nonce => {
          return this.ddp.call({ methodName: 'layer/auth', params: [nonce]});
        }).then(sessionId => {
          return TSLayerService.authenticateAsync(sessionId)
        });
      }
    }).catch(error => {
      console.error('Unable to complete layer flow', error);
    });
  }

  componentWillMount() {
    let ddp = this.ddp;

    ddp.initialize()
    .then(() => {
      return ddp.isLoggedIn()
    })
    .then((res) => {
      if (res.token) {
        ddp.loginWithToken(res.token);
      }

      return Promise.resolve(res);
    }).then((res) => {
      if (res.token) {
        this.onLogin(res);
      } else {
        this.setState({ loggedIn: false });
      }
    })
  }

  render() {
    if (!this.state.loggedIn || !this.state.isActive) {
      return <OnboardingNavigator
        loggedIn={this.state.loggedIn}
        isActive={this.state.isActive}
        integrations={this.state.integrations}
        me={this.state.me} 
        categories={this.state.categories}
        myTags={this.state.myTags}
        onLogin={this.onLogin.bind(this)}
        ddp={this.ddp} /> 
    }

    return <RootNavigator
      me={this.state.me}
      integrations={this.state.integrations}
      categories={this.state.categories}
      myTags={this.state.myTags}
      loggedIn={this.state.loggedIn}
      onLogout={this.onLogout.bind(this)}
      onLogin={this.onLogin.bind(this)}
      candidate={this.state.candidate}
      history={this.state.history}
      users={this.state.users}
      settings={this.state.settings}
      numTotalConversations={this.state.numTotalConversations}
      ddp={this.ddp} />
  }
}

module.exports = LayoutContainer;