import TSDDPClient from '../../lib/ddpclient';

const logger = new (require('../../modules/Logger'))('DDPService');

class DDPService extends TSDDPClient {

  resubscribe() {
    logger.debug('called subscribe')
  }

  async _subscribeMe() {
    await this.ddp.subscribe({ pubName: 'me' })

    this.ddp.collections.observe(() => {
      return this.ddp.collections.users.findOne({ _id: this.ddp.currentUserId });
    }).subscribe(currentUser => {
      if (currentUser) {
        this.store.dispatch({
          type: 'SET_ME',
          me: currentUser
        })
      }
    });
  }
}

export default DDPService;
