import TSDDPClient from '../../lib/ddpclient';

const logger = new (require('../../modules/Logger'))('DDPService');

class DDPService extends TSDDPClient {

  resubscribe(dispatch) {
    this._subscribeMe(dispatch);
    this._subscribeIntegrations(dispatch);
    this._subscribeMyTags(dispatch);
    this._subscribeTagCategories(dispatch)
    this._subscribeCandidates(dispatch)
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
}

export default DDPService;
