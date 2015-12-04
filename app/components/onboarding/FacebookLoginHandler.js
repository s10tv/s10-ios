// constants
const logger = new (require('../../../modules/Logger'))('FacebookLoginHandler');

class FacebookLoginHandler {

  constructor(ddp) {
    this.ddp = ddp;
  }

  onLogin(accessTokenString, dispatch) {
    return this.ddp.call({
      methodName: 'login',
      params: [{ facebook: { accessToken: accessTokenString }}]})
    .then((result) => {
      logger.debug(`Login result from Facebook: ${JSON.stringify(result)}`)

      dispatch({
        type: 'LOGIN_FROM_FB',
        userId: result.id,
        resumeToken: result.token,
        isNewUser: result.isNewUser,
        expiryDate: result.tokenExpires.getTime(),
        userTriggered: true,
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
