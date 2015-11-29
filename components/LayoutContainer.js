let React = require('react-native');

let {
  AppRegistry,
  AlertIOS,
  NativeAppEventEmitter,
  View,
  TabBarIOS,
} = React;

let Analytics = require('../modules/Analytics');
let BridgeManager = require('../modules/BridgeManager');
let Intercom = require('../modules/Intercom');

let OnboardingNavigator = require('./onboarding/OnboardingNavigator');
let RootNavigator = require('./RootNavigator');
let Loader = require('./lib/Loader');

let TSLayerService = React.NativeModules.TSLayerService;

let SHEET = require('./CommonStyles').SHEET;
let Logger = require('../lib/Logger');

let Digits = require('react-native-fabric-digits');
let { DigitsAuthenticateManager } = Digits;

let FBSDKLogin = require('react-native-fbsdklogin');
let { FBSDKLoginManager } = FBSDKLogin;

class LayoutContainer extends React.Component {

  constructor(props: {}) {
    super(props);
    this.ddp = props.ddp;
    this.logger = new Logger(this);

    const state = props.layerService.store.getState();
    this.state = {
      numTotalConversations: state.allCount,
      numUnreadConversations:  state.unreadCount,
    }
  }

  componentWillMount() {
    this.props.layerService.store.subscribe(this.updateLayerState);
  }

  updateLayerState() {
    const state = this.props.layerService.store.getState();
    this.setState({
      numTotalConversations: state.allCount,
      numUnreadConversations: state.unreadCount,
    }) 
  }

  formatUser(user) {
    if (!user) {
      return user;
    }
    user.userId = user._id; // for layer

    let {firstName, lastName, gradYear} = user;

    const generateDisplayName = (length) => {
      let displayName = firstName;
      if (lastName && displayName.length + lastName.length < length) {
        displayName += ` ${lastName}`;
      }

      if (gradYear && displayName.length + gradYear.length < length) {
        displayName += ` ${gradYear}`;
      }
      return displayName;
    }

    user.shortDisplayName = generateDisplayName(20);
    user.displayName = user.shortDisplayName; // for Layer

    user.longDisplayName = generateDisplayName(30);

    // for layer
    user.avatarUrl = (user.avatar ? user.avatar.url : undefined) ||
      'https://s10tv.blob.core.windows.net/s10tv-prod/defaultbg.jpg';

    user.coverUrl = (user.cover ? user.cover.url : undefined) ||
      'https://s10tv.blob.core.windows.net/s10tv-prod/defaultbg.jpg';

    return user;
  }

  async onLogout() {
    Analytics.userDidLogout();

    try {
      await TSLayerService.deauthenticateAsync();
    } catch (err) {
      this.logger.warning(`Cannot deauthenticate Layer ${err}`);
    }

    DigitsAuthenticateManager.logout();
    FBSDKLoginManager.logOut();

    try {
      await this.ddp.logout()
    } catch (err) {
      this.logger.warning(`Cannot logout of Meteor ${err}`);
    }

    try {
      await BridgeManager.setDefaultAccount(null)
    } catch (err) {
      this.logger.warning(`Cannot deauthenticate from METAccount ${err}`);
    }
    
    this.setState({ 
      loggedIn: false,
      isActive: false,
      me: null,
      users: null,
      integrations: null,
      categories: null,
      myTags: null,
      history: null,
      candidate: null,
      settings: null,
      numTotalConversations: null,
      numUnreadConversations: null,
      isCWLRequired: null,
    });
  }

  _subscribeSettings(userRequired = true) {
    let ddp = this.ddp;

    ddp.subscribe({ pubName: 'settings', userRequired: userRequired })
    .then(() => {
      ddp.collections.observe(() => {
        if (ddp.collections.settings) {
          return ddp.collections.settings.find({});
        }
      }).subscribe(settings => {
        this.logger.debug('got settings', settings);
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

        if (indexedSettings.CWLRequired !== undefined && 
            indexedSettings.tfCWLRequired !== undefined) {
          let isCWLRequired = BridgeManager.isRunningTestFlightBeta() ? 
              indexedSettings.tfCWLRequired.value :
              indexedSettings.CWLRequired.value;
          this.setState({ isCWLRequired: isCWLRequired });
        }
      });
    })
    .catch(err => { this.logger.error(JSON.stringify(err)) })
  }

  /** 
   * account: { userId, resumeToken, expiryDate, isNewUser, hash }
   */
  async onUserLogin(account) {
    if (!account) {
      this.logger.warning('invalid account for onUserLogin');
      return;
    }

    const { userId, resumeToken, expiryDate, isNewUser, intercom, userTriggered } = account;
    if (!userId || !resumeToken || !expiryDate || (isNewUser == undefined)) {
      this.logger.warning('invalid info provided to onUserLogin');
      return
    }

    this.logger.debug(`onLogin intercom=${JSON.stringify(intercom)}
      newUser=${isNewUser} userTriggered=${userTriggered}`);

    if (intercom != null) {
      Intercom.setHMAC(intercom.hmac, intercom.data);
    }

    Analytics.userDidLogin(userId, isNewUser);

    await BridgeManager.setDefaultAccount(account)

    this.onLogin()
  }

  async _layerLogin() {
    try {
      await TSLayerService.connectAsync();
      const isAuthenticated = await TSLayerService.isAuthenticatedAsync();
      if (isAuthenticated) {
        return;
      }
      const nonce = await TSLayerService.requestAuthenticationNonceAsync();
      const sessionId = await this.ddp.call({ methodName: 'layer/auth', params: [nonce]});
      await TSLayerService.authenticateAsync(sessionId);

      this.logger.debug('Layer authenticated.');
    } catch (error) {
      this.logger.warning(`Unable to complete layer flow: ${error.toString()}`)
    }
  }

  async _ddpLogin() {
    this.logger.debug('On DDP Loggin');
    let ddp = this.ddp;

    const defaultAccount = await BridgeManager.getDefaultAccountAsync()

    if (defaultAccount) {

      const { userId, resumeToken } = defaultAccount;

      // token exists. assume that the user is logged in until proven wrong.
      if (resumeToken) {
        this.logger.debug(`Resume token exists. Logging in`);

        this.setState({ loggedIn: true, isActive: true });

        if (!this.state.me) {
          let defaultUser = {
            userId: userId, 
            firstName: 'FirstName',
            lastName: 'lastName',
            displayName: 'FirstName LastName',
            avatarUrl: 'https://s3.amazonaws.com/profile_photos/25339545481234.vWxFtxXy7Xw3ntEkiPMu_27x27.png',
            coverUrl: 'https://s10tv.blob.core.windows.net/s10tv-prod/defaultbg.jpg',
            connectedProfiles: []
          }
          this.setState({ me: defaultUser });
        }

        await this._layerLogin()

        try {
          await ddp.initialize()
        } catch (err) {
          // there is no network
          this.logger.warning(JSON.stringify(err));
          return; 
        }

        try {
          this._subscribeSettings(false);
          await ddp.loginWithToken(resumeToken)
          this.onLogin()
        } catch (err) {
          // This token is stale. Need the user to re-login
          this.logger.warning(JSON.stringify(err));
          this.setState({ loggedIn: false });
        }

        return;
      }
    }
    
    await ddp.initialize()
    this._subscribeSettings(false);
    this.setState({ loggedIn: false });
  }

  async onLogin() {
    const ddp = this.ddp;

    this.setState({ loggedIn: true });
    this._layerLogin()
    this._subscribeSettings()

    this.ddp.subscribe({ pubName: 'me' })
    .then(() => {
      ddp.collections.observe(() => {
        if (ddp.collections.users) {
          return ddp.collections.users.findOne({ _id: ddp.currentUserId });
        }
      }).subscribe(currentUser => {
        if (currentUser) {
          if (currentUser.firstName && currentUser.lastName) {
            Analytics.setUserFullname(`${currentUser.firstName} ${currentUser.lastName}`);
          }

          this.setState({ me: this.formatUser(currentUser) });
        }
      });

      ddp.collections.observe(() => {
        if (ddp.collections.users) {
          return ddp.collections.users.find({});
        }
      }).subscribe(users => {
        if (users) {
          let formattedUsers = users.map(user => {
            return this.formatUser(user);
          })
          this.setState({ users: formattedUsers });
        }
      });
    })
    .catch(err => { this.logger.error(JSON.stringify(err)) });

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
    })
    .catch(err => { this.logger.error(JSON.stringify(err)) });

    this.ddp.subscribe({ pubName: 'hashtag-categories' })
    .then(() => {
      ddp.collections.observe(() => {
        if (ddp.collections.categories) {
          return ddp.collections.categories.find({});
        }
      }).subscribe(categories=> {
        this.setState({ categories: categories });
      });
    })
    .catch(err => { this.logger.error(JSON.stringify(err)) });

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
    })
    .catch(err => { this.logger.error(JSON.stringify(err)) });

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
    })
    .catch(err => { this.logger.error(JSON.stringify(err)) });

    this.ddp.subscribe({ pubName: 'activities', params:[ddp.currentUserId] })
    .then(() => {
      ddp.collections.observe(() => {
        if (ddp.collections.activities) {
          return ddp.collections.activities.find({ userId: ddp.currentUserId });
        }
      }).subscribe(activities => {
        this.setState({ myActivities: activities });
      });
    })
    .catch(err => { this.logger.error(JSON.stringify(err)) });
  }

  reportUser(user) {
    if (user) {
      AlertIOS.alert(
        `Report ${user.firstName}?`,
        "",
        [
          {text: 'Cancel', onPress: () => null },
          {text: 'Report', onPress: () => {
            return this.ddp.call({ methodName: 'user/report', params: [user._id, 'Reported'] })
            .then(() => {
              Analytics.track("User: Confirmed Block")
              AlertIOS.alert(`Reported ${user.firstName}`, 
                'Thanks for your input. We will look into this shortly.');
            })
          }},
        ]
      )
    }
  }

  updateProfile(key, value) {
    let myInfo = {};
    myInfo[key] = value;
    return this.props.ddp.call({ methodName: 'me/update', params: [myInfo] })
    .catch(err => {
      this.logger.error(JSON.stringify(err));
      AlertIOS.alert('Missing Some Info!', err.reason);
    })
  }

  componentWillMount() {
    this._ddpLogin()

    this.setState({
      showMoreOptionsListener: NativeAppEventEmitter.addListener('Profile.showMoreOptions', (userId) => {
        let user = this.ddp.collections.users.findOne({ _id: userId });
        this.reportUser(user)
      }.bind(this)),
    })
  }

  componentWillUnmount() {
    this.state.showMoreOptionsListener.remove()
    this.setState({
      showMoreOptionsListener: null
    })
  }

  render() {
    this.logger.debug(`Rendering layout container. loggedIn=${this.state.loggedIn}
      isActive=${this.state.isActive}`);

    if (!this.state.loggedIn || !this.state.isActive) {
      return <OnboardingNavigator
        loggedIn={this.state.loggedIn}
        isActive={this.state.isActive}
        integrations={this.state.integrations}
        me={this.state.me} 
        categories={this.state.categories}
        myTags={this.state.myTags}
        onLogin={this.onUserLogin.bind(this)}
        onLogout={this.onLogout.bind(this)}
        settings={this.state.settings}
        isCWLRequired={this.state.isCWLRequired}
        updateProfile={this.updateProfile.bind(this)}
        ddp={this.ddp} /> 
    }

    return <RootNavigator
      me={this.state.me}
      integrations={this.state.integrations}
      categories={this.state.categories}
      myTags={this.state.myTags}
      loggedIn={this.state.loggedIn}
      reportUser={this.reportUser.bind(this)}
      onLogout={this.onLogout.bind(this)}
      onLogin={this.onUserLogin.bind(this)}
      candidate={this.state.candidate}
      history={this.state.history}
      users={this.state.users}
      settings={this.state.settings}
      numTotalConversations={this.state.numTotalConversations}
      numUnreadConversations={this.state.numUnreadConversations}
      updateProfile={this.updateProfile.bind(this)}
      ddp={this.ddp} />
  }
}

module.exports = LayoutContainer;