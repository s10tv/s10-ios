
const logger = new (require('../../modules/Logger'))('DDPService');

class DDPService {

  constructor(ddp, store) {
    this.ddp = ddp;
    this.store = store;

    this.store.subscribe(() => {
      const state = store.getState();

    })
  }

  initialize() {
    return this.ddp.initialize();
  }

  loginWithToken(resumeToken) {
    return this.ddp.loginWithToken(resumeToken)
  }

  async subscribe() {
    this._subscribeMe();
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
