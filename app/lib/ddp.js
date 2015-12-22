import TSDDPClient from '../../lib/ddpclient';
import BridgeManager from '../../modules/BridgeManager';
import CWLChecker from '../util/CWLChecker';
import Session from '../../native_modules/Session';
import Analytics from '../../modules/Analytics';
import ResumeTokenHandler from '../util/ResumeTokenHandler'

const logger = new (require('../../modules/Logger'))('DDPService');

class DDPService extends TSDDPClient {

  constructor(wsurl) {
    super(wsurl);

    this.resumeTokenHandler = new ResumeTokenHandler(this, Session);

    this.ddpClient.addListener('connected', (error) => {
      this.connected = true;

      logger.debug('[ddp] connected');
      if(this.closeReason) {
        logger.debug('[ddp] was closed before with close reason ' + this.closeReason);
        // if this is a result of a reconnect of any kind
        this.resumeTokenHandler.handle(this.dispatch)
        .then(() => {
          this.resubscribe();
        })
      }
    })

    this.ddpClient.addListener('failed', (error) => {
      logger.debug('[ddp] failed occurred');
      this.connected = false;
      this.loggedIn = false;
      this.closeReason = 'failed'
    })

    this.ddpClient.addListener('socket-close', (error) => {
      logger.debug('[ddp] socket-close occurred');
      this.connected = false;
      this.loggedIn = false;
      this.closeReason = 'socket-close'
    })

    this.ddpClient.addListener('socket-error', (error) => {
      logger.debug('[ddp] socket-error occurred');
      this.connected = false;
      this.loggedIn = false;
      this.closeReason = 'socket-error'
    })
  }

  resubscribe() {
    this.subscribeSettings();
    this._subscribeMe(this.dispatch);
    this._subscribeIntegrations(this.dispatch);
    this._subscribeMyTags(this.dispatch);
    this._subscribeMyCourses(this.dispatch);
    this._subscribeTagCategories(this.dispatch)
    this._subscribeCandidates(this.dispatch)
    this._subscribeMyCheckins(this.dispatch)
  }

  loginWithFacebook(accessToken) {
    return new Promise((resolve, reject) => {
      this.ddpClient.call(
        "login",
        [{ facebook: { accessToken: accessToken, deviceId: BridgeManager.deviceId() }}],
        (err, res) => {
          if (err) { return reject(err) }
          return resolve(res);
        }
      )
    })
    .then(({ id, token, tokenExpires, isNewUser, intercomHash, isActive }) => {
      logger.info(`Logged in with Facebook`);
      this._onLogin(id)

      return Promise.resolve({
        userId: id,
        resumeToken: token,
        expiryDate: tokenExpires.getTime(),
        isNewUser: isNewUser || false,
        intercomHash: intercomHash,
        isActive: isActive,
      });
    })
    .catch(err => {
      logger.error(err);
    })
  }

  loginWithDigits(digitsResponse) {
    if (!digitsResponse) {
      logger.info(`Got undefined digits response when logging in with digits`);
      return;
    }

    digitsResponse.deviceId = BridgeManager.deviceId();
    return new Promise((resolve, reject) => {
      this.ddpClient.call(
        "login",
        [{ digits: digitsResponse}],
        (err, res) => {
          if (err) { return reject(err) }
          return resolve(res);
        }
      )
    })
    .then(({ id, token, tokenExpires, isNewUser, intercomHash, isActive }) => {
      logger.info(`Logged in with Digits`);
      this._onLogin(id)

      return Promise.resolve({
        userId: id,
        resumeToken: token,
        expiryDate: tokenExpires.getTime(),
        isNewUser: isNewUser || false,
        intercomHash,
        isActive,
      });
    })
    .catch(err => {
      logger.error(err);
    })
  }

  loginWithToken(token) {
    if (token) {
      return new Promise((resolve, reject) => {
        this.ddpClient.call("login", [{ tsresume: token, deviceId: BridgeManager.deviceId() }], (err, res) => {
          if (err) {
            switch (err.error) {
              case 403: // You have been logged out by server (expired token)
                logger.warning(err.reason)
                break;
              default:
                logger.error(err);
            }
            return resolve({});
          }

          logger.info(`logged in with resume token`);
          this._onLogin(res.id)

          logger.debug(`token=${token}`)

          return resolve({
            userId: res.id,
            resumeToken: token,
            expiryDate: res.tokenExpires.getTime(),
            isActive: res.isActive,
            intercomHash: res.intercomHash,
            isNewUser: res.isNewUser,
          });
        });
      });
    } else {
      return Promise.resolve({})
    }
  }

  logout() {
    return
      this.call({ methodName: "logout"})
      .catch(err => {
        logger.error(err);
      })
  }

  _generateShortDisplayName = (user, length) => {
    if (!user.firstName) {
      return '';
    }

    let displayName = user.firstName;

    if (user.lastName && displayName.length + user.lastName.length < length) {
      displayName += ` ${user.lastName}`;
    }

    if (user.gradYear && displayName.length + user.gradYear.length < length) {
      displayName += ` ${user.gradYear}`;
    }
    return displayName;
  }


  _formatUser(user) {
    if (!user) {
      return user;
    }

    const avatarUrlOverride = (user.avatar && user.avatar.url) ?
      { avatarUrl: user.avatar.url } : {};

    const coverUrlOverride = (user.cover && user.cover.url) ?
      { coverUrl: user.cover.url } : {};

    return Object.assign({ courses: [] }, user, avatarUrlOverride, coverUrlOverride, {
      userId: user._id,
      displayName: this._generateShortDisplayName(user, 20),
      longDisplayName: this._generateShortDisplayName(user, 30),
    })
  }

  _subscribeMe(dispatch) {
    logger.info(`subscribing me`);
    this.subscribe({ pubName: 'me' })
    .then((subId) => {
      this.collections.observe(() => {
        return this.collections.users.findOne({ _id: this.currentUserId });
      }).subscribe(currentUser => {
        if (currentUser) {
          dispatch({
            type: 'SET_ME',
            me: this._formatUser(currentUser)
          })

          Session.setFullname(`${currentUser.firstName} ${currentUser.lastName}`);
          Session.setFirstName(currentUser.firstName);
          Session.setLastName(currentUser.lastName);

          if (currentUser.avatar) {
            Session.setAvatarURL(currentUser.avatar.url);
          }

          if (currentUser.cover) {
            Session.setCoverURL(currentUser.cover.url);
          }

          Analytics.updateFullname();
        }
      });
    })
  }

  _subscribeIntegrations(dispatch) {
    this.subscribe({ pubName: 'integrations' })
    .then((subId) => {
      logger.info(`got integrations subscription back`);
      this.collections.observe(() => {
        return this.collections.integrations.find({});
      }).subscribe(integrations => {
        integrations.sort((one, two) => {
          return one.status == 'linked' ? -1 : 1;
        })

        logger.debug(`[integrations]: ddp sent ${integrations.length} integrations`)
        dispatch({
          type: 'SET_INTEGRATIONS',
          integrations: integrations,
        })
      });
    })
  }

  _subscribeMyTags(dispatch) {
    this.subscribe({ pubName: 'my-tags' })
    .then((subId) => {
      this.collections.observe(() => {
        return this.collections.mytags.findOne({});
      }).subscribe(user => {
        if (user && user.tags) {
          user.tags.forEach((tag) => {
            tag.isMine = true;
          })

          dispatch({
            type: 'SET_MY_TAGS',
            mytags: user.tags,
          })
        }
      });
    })
  }

  _subscribeTagCategories(dispatch) {
    this.subscribe({ pubName: 'hashtag-categories' })
    .then((subId) => {
      this.collections.observe(() => {
        return this.collections.categories.find({});
      }).subscribe(categories => {
        dispatch({
          type: 'SET_TAG_CATEGORIES',
          categories: categories,
        })
      });
    })
  }

  _subscribeMyCourses(dispatch) {
    this.subscribe({ pubName: 'my-courses' })
    .then((subId) => {
      this.collections.observe(() => {
        return this.collections.mycourses.findOne({});
      }).subscribe(user => {
        if (user && user.courses) {
          dispatch({
            type: 'SET_MY_COURSES',
            mycourses: user.courses,
          })
        }
      });
    })
  }


  _subscribeCandidates(dispatch) {
    this.subscribe({ pubName: 'candidate-discover' })
    .then(() => {
      this.collections.observe(() => {
        return this.collections.candidates.find({});
      }).subscribe(candidates => {
        let activeCandidates = candidates.filter((candidate) => {
          return candidate.type == 'active'
        })

        let historyCandidates = candidates.filter((candidate) => {
          return candidate.type == 'expired'
        })

        if (activeCandidates.length > 0) {
          const [ activeCandidate ] = activeCandidates;
          activeCandidate.user = this._formatUser(activeCandidate.user);

          // because we ship the {@code view()} of the user down to the client, the user that
          // gets shipped actually doesn't have an id field. Need to fill it in.
          activeCandidate.user.userId = activeCandidate.userId

          dispatch({
            type: 'SET_ACTIVE_CANDIDATE',
            candidate: activeCandidate,
          })
        }

        dispatch({
          type: 'SET_HISTORY_CANDIDATE',
          candidates: historyCandidates,
        })
      });
    })
    .catch(err => { logger.error(err) });
  }

  _subscribeMyCheckins(dispatch) {
    this.subscribe({ pubName: 'my-events' })
    .then(() => {
      this.collections.observe(() => {
        return this.collections.myevents.findOne({});
      }).subscribe(user => {
        if (user && user.checkins) {
          dispatch({
            type: 'SET_MY_CHECKINS',
            checkins: user.checkins,
          })
        }
      });
    })
    .catch(err => { logger.error(err) });
  }

  subscribeSettings({ userRequired } = { userRequired: true}) {
    this.subscribe({ pubName: 'settings', userRequired: userRequired })
    .then((subId) => {
      this.collections.observe(() => {
        return this.collections.settings.find({});
      }).subscribe(settings => {
        const indexedSettings =  {};
        settings.forEach((setting) => {
          indexedSettings[setting._id] = setting;
        });

        if (indexedSettings.upgradeUrl && indexedSettings.hardMinBuild) {
          const currentBuild = BridgeManager.build();
          if (currentBuild < indexedSettings.hardMinBuild.value) {
            this.dispatch({
              type: 'DISPLAY_POPUP_MESSAGE',
              dialog: {
                visible: true,
                title: 'Upgrade Needed',
                message: 'Your version of Taylr is no longer supported. Please upgrade =)',
                actionKey: 'HARD_UPGRADE',
                hardUpgradeURL:  indexedSettings.upgradeUrl.value
              }
            })
          }
        }

        if (indexedSettings.nextMatchDate) {
          logger.debug(`got nextMatchDate=${indexedSettings.nextMatchDate.value}`)
          this.dispatch({
            type: 'SET_NEXT_MATCH_DATE',
            nextMatchDate: indexedSettings.nextMatchDate.value,
          })
        }

        if (indexedSettings.CWLWhitelist) {
          const currentVersion = BridgeManager.version();
          const isRunningTestFlightBeta = BridgeManager.isRunningTestFlightBeta();
          const { version, showCWLForTestFlight } = indexedSettings.CWLWhitelist.value;

          const isCWLRequired = new CWLChecker().checkCWL({
            version,
            currentVersion,
            showCWLForTestFlight,
            isRunningTestFlightBeta,
          })

          logger.debug(`checking CWL: isCWLRequired=${isCWLRequired}`);
          this.dispatch({
            type: 'SET_IS_CWL_REQUIRED',
            isCWLRequired,
          })
        }

        if (indexedSettings.accountStatus) {
          if (indexedSettings.accountStatus.value !== 'active') {
            this.resetToLoginFn();
          } else {
            this.resetToMainScreenFn();
          }

        }
      });
    })
  }
}

export default DDPService;
