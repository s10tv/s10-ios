const logger = new (require('../../modules/Logger'))('ResumeTokenHandler');

const ERRORS = {
  COULD_NOT_LOG_IN: 'could-not-log-in',
  NO_NETWORK: 'no-network',
  NOT_LOGGED_IN: 'not-logged-in',
  TOKEN_NOT_FOUND: 'token-not-found',
  EXPIRED_TOKEN: 'expired-token',
};

class ResumeTokenHandler {

  constructor(ddp, session) {
    this.ddp = ddp;
    this.session = session;
    this.errors = ERRORS;
  }

  handle(dispatch) {
    if (!this.ddp.connected) {
      logger.warning('Cannot connect to DDP server.');
      return Promise.reject(ERRORS.NO_NETWORK);
    }
    return Promise.resolve(true)
    .then(() => {
      if (!this.session || !this.session.initialValue) {
      logger.warning('Cannot connect to DDP server.');
        return Promise.reject(ERRORS.NOT_LOGGED_IN);
      }

      const { userId, resumeToken } = this.session.initialValue();

      logger.debug(`userId:${userId} resumeToken:${resumeToken}`)

      if (!userId || !resumeToken) {
        return Promise.reject(ERRORS.TOKEN_NOT_FOUND);
      }

      dispatch({
        type: 'LOGIN_FROM_RESUME',
        userId,
        resumeToken,
      });

      return this.ddp.loginWithToken(resumeToken);
    })
    .then((loginResult) => {
      if (loginResult) {
        dispatch({
          type: 'SET_IS_ACTIVE',
          isActive: (loginResult.isActive || false)
        })

        return Promise.resolve(loginResult);
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
          dispatch({
            type: 'LOGOUT',
          });
          break;
        case ERRORS.TOKEN_NOT_FOUND:
          logger.debug('Account exists, but no token was found. Bug?');
          dispatch({
            type: 'LOGOUT',
          });
          break;
        case ERRORS.EXPIRED_TOKEN:
          logger.debug('Resume token expired.')
          dispatch({
            type: 'LOGOUT',
          });
          break;
        default:
          logger.error(err);
      }
      return Promise.reject(ERRORS.COULD_NOT_LOG_IN);
    })
  }
}

module.exports = ResumeTokenHandler;
