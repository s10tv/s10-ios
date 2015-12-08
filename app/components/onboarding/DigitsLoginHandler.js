// constants
const logger = new (require('../../../modules/Logger'))('DigitsLoginHandler');

class DigitsLoginHandler {

  constructor(ddp) {
    this.ddp = ddp;
  }

  onLogin(digitsResponse, dispatch) {
    return this.ddp.loginWithDigits(digitsResponse)
    .then((result) => {
      dispatch({
        type: 'LOGIN_FROM_DIGITS',
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

module.exports = DigitsLoginHandler;
