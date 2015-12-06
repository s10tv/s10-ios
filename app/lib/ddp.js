import TSDDPClient from '../../lib/ddpclient';

const logger = new (require('../../modules/Logger'))('DDPService');

class DDPService extends TSDDPClient {

  resubscribe(dispatch) {
    this._subscribeMe(dispatch);
    this._subscribeIntegrations(dispatch);
    this._subscribeUsers(dispatch);
  }

  _generateShortDisplayName = (user, length) => {
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

    return Object.assign({}, user, avatarUrlOverride, coverUrlOverride, {
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
          logger.info(`got current user=${this._formatUser(currentUser)}`);

          dispatch({
            type: 'SET_ME',
            me: this._formatUser(currentUser)
          })
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

  _subscribeUsers(dispatch) {
    this.collections.observe(() => {
      return this.collections.users.find({});
    }).subscribe(users => {
      dispatch({
        type: 'SET_USERS',
        users: users,
      });
    });
  }
}

export default DDPService;
