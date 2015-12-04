import TSDDPClient from '../../lib/ddpclient';

const logger = new (require('../../modules/Logger'))('DDPService');

class DDPService extends TSDDPClient {

  resubscribe(dispatch) {
    logger.debug('DDP service resubscribe');
    this._subscribeMe(dispatch)
  }

  _subscribeMe(dispatch) {
    this.subscribe({ pubName: 'me' })
    .then((subId) => {
      this.collections.observe(() => {
        return this.collections.users.findOne({ _id: this.currentUserId });
      }).subscribe(currentUser => {
        if (currentUser) {
          dispatch({
            type: 'SET_ME',
            me: currentUser
          })
        }
      });
    })
  }
}

export default DDPService;
