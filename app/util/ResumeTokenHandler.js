const logger = new (require('../../modules/Logger'))('ResumeTokenHandler');

const ERRORS = {
  NO_NETWORK: 'no-network',
  NOT_LOGGED_IN: 'not-logged-in',
  EXPIRED_TOKEN: 'expired-token',
};

class ResumeTokenHandler {

  constructor(ddp, session) {
    this.ddp = ddp;
    this.session = session;
  }

  handle(dispatch) {
    return this.ddp.initialize()
    .then(() => {
      if (!this.ddp.connected) {
        logger.warning('Cannot connect to DDP server.');
        return Promise.reject(ERRORS.NO_NETWORK);
      }
      return Promise.resolve(true);
    })
    .then(() => {
      if (!this.session || !this.session.initialValue) {
        return Promise.reject(ERRORS.NOT_LOGGED_IN);
      }

      const { userId, resumeToken } = this.session.initialValue;

      if (!userId || !resumeToken) {
        return Promise.reject(ERRORS.NOT_LOGGED_IN);
      }

      dispatch({
        type: 'LOGIN_FROM_RESUME',
        userId,
        resumeToken,
      });

      return this.ddp.loginWithToken(resumeToken);
    })
    .then((loginResult) => {
      if (loginResult && loginResult.resumeToken) {
        return this.ddp.subscribe();
      }
      return Promise.reject(ERRORS.EXPIRED_TOKEN)
    })
    .catch(err => {
      switch (err) {
        case ERRORS.NO_NETWORK:
          logger.warning('No network for DDP initialization.');
          break;
        case ERRORS.NOT_LOGGED_IN:
          logger.debug('No resume token found.');
          break;
        case ERRORS.EXPIRED_TOKEN:
          logger.debug('Resume token expired.')
          break;
        default:
          console.trace(err);
          logger.error(err);
      }
      return false;
    })
  }
}

module.exports = ResumeTokenHandler;
