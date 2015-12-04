// constants
const logger = new (require('../../../modules/Logger'))('FacebookLoginHandler');

class FacebookLoginHandler {

  constructor(ddp) {
    this.ddp = ddp;
  }

  onLogin(accessTokenString, dispatch) {
    return this.ddp.loginWithFacebook(accessTokenString)
    .then((result) => {
      logger.debug(`Login result from Facebook: ${JSON.stringify(result)}`)

      dispatch({
        type: 'LOGIN_FROM_FB',
      })

      if (result.isNewUser) {
        // TODO(qimingfang): navigate through onboarding navigator
      }

      return Promise.resolve(result);
    })
    .catch(err => {
      logger.error(err);
    })
  }
}

module.exports = FacebookLoginHandler;
