let React = require('react-native');

let DDPClient = require("ddp-client");
let _ = require('lodash');

const logger = new (require('../modules/Logger'))('TSDDPClient')

class TSDDPClient {
  constructor(wsurl) {
    this.ddpClient = new DDPClient({
      autoReconnect : true,
      autoReconnectTimer : 500,
      maintainCollections : true,
      ddpVersion : '1',  // ['1', 'pre2', 'pre1'] available
      url: wsurl || 'wss://s10-dev.herokuapp.com/websocket'
    });

    this.ddpClient.EJSON.addType('oid', function fromJSONValue(value) {
      return value;
    })

    // this.ddpClient.on('message', (msg) => {
    //   logger.debug(msg);
    // });

    this.ddpClient.collections.addCollection('users');
    this.ddpClient.collections.addCollection('activities');
    this.ddpClient.collections.addCollection('settings');
    this.ddpClient.collections.addCollection('integrations');
    this.ddpClient.collections.addCollection('candidates');
    this.ddpClient.collections.addCollection('categories');
    this.ddpClient.collections.addCollection('mytags');
    this.ddpClient.collections.addCollection('suggestions');

    this.collections = this.ddpClient.collections;
    this.subscriptions = {};

    this.connected = false;
    this.loggedIn = false;
    this.loadingCurrentUser = false;
    this.loadingSettings = false;

    this.beforeInitPromises =[];
    this.beforeLoginPromises = [];
    this.currentUserPromises = [];
    this.settingsPromises = [];

    this.currentUserId = undefined;
  }

  __wait(condition, promises) {
    return new Promise((resolve, reject) => {
      if (condition) {
        promises.push(resolve);
      } else {
        resolve(true);
      }
    })
  }

  __waitForConnection() {
    return this.__wait(!this.connected, this.beforeInitPromises);
  }

  __waitForLogin() {
    return this.__wait(!this.loggedIn, this.beforeLoginPromises);
  }

  __resolveBeforeInitPromises() {
    this.beforeInitPromises.forEach((resolve) => { resolve(true) })
  }

  __resolveBeforeLoginPromises() {
    this.beforeLoginPromises.forEach((resolve) => { resolve(true) })
  }

  initialize() {
    if (this.connected) {
      return Promise.resolve(true);
    }

    return new Promise((resolve, reject) => {
      this.ddpClient.connect((error, wasReconnect) => {
        // If autoReconnect is true, this back will be invoked each time
        // a server connection is re-established
        if (error) {
          return reject(error);
        }

        this.connected = true;
        this.__resolveBeforeInitPromises()

        logger.debug('DDP initialized');
        resolve(true);
      });
    });
  }

  isConnected() {
    return this.currentUserId && this.loggedIn;
  }

  _onLogin(currentUserId) {
    this.loggedIn = true;
    this.currentUserId = currentUserId;
    this.__resolveBeforeLoginPromises();
  }

  loginWithFacebook(accessToken) {
    return new Promise((resolve, reject) => {
      this.ddpClient.call(
        "login",
        [{ facebook: { accessToken: accessToken }}],
        (err, res) => {
          if (err) { return reject(err) }
          return resolve(res);
        }
      )
    })
    .then(({ id, token, tokenExpires, isNewUser }) => {
      logger.info(`Logged in with Facebook`);
      this._onLogin(id)

      logger.info(`id: ${id}, token: ${token}: isNewUser: ${isNewUser}`)

      return Promise.resolve({
        userId: id,
        resumeToken: token,
        expiryDate: tokenExpires.getTime(),
        isNewUser: isNewUser || false,
      });
    })
    .catch(err => {

    })
  }

  loginWithToken(token) {
    if (token) {
      return new Promise((resolve, reject) => {
        this.ddpClient.call("login", [{ resume: token }], (err, res) => {
          if (err) {
            switch (err.error) {
              case 403: // You have been logged out by server (expired token)
                logger.warning(err.reason)
                break;
              default:
                logger.error(err);
            }
            return resolve({});
          }

          logger.info(`logged in with resume token`);
          this._onLogin(res.id)

          return resolve({
            userId: res.id,
            resumeToken: token,
            expiryDate: res.tokenExpires.getTime(),
          });
        });
      });
    } else {
      return Promise.resolve({})
    }
  }

  logout() {
    return
      this.call({ methodName: "logout"})
      .catch(err => {
        logger.error(err);
      })
  }

  close() {
    this.__resolveBeforeInitPromises();
    return this.ddpClient.close();
  }

  subscribe(options) {
    let { pubName, params, userRequired } = options;

    if (!pubName) {
      logger.error('Cannot subscribe to empty publication');
    }

    userRequired = userRequired === undefined ? true : userRequired;
    params = params || [];

    let userInSessionPromise = userRequired ?
      this.__waitForLogin() :
      Promise.resolve(true) ;

    return this.__waitForConnection()
      .then(() => userInSessionPromise)
      .then(() => {
        return new Promise((resolve, reject) => {
          let subId = this.ddpClient.subscribe(pubName, params, () => {
            logger.info(`subscribed ${pubName} >>> ${subId}`);
            return resolve(subId);
          });
        });
      })
      .catch(err => {
        logger.error();
      })
  }

  unsubscribe(subId) {
    this.ddpClient.unsubscribe(subId);
  }

  call(options) {
    let { methodName, params } = options;

    if (!methodName) {
      logger.error('Cannot call method without method name');
    }

    if (params && !_.isArray(params)) {
      logger.warning('Params must be passed as an array to ddp.call');
    }

    return this.__waitForConnection()
      .then(() => {
        return new Promise((resolve, reject) => {
          this.ddpClient.call(methodName, params,
            (err, result) => { // callback which returns the method call results
              if (err) {
                reject(err);
              } else {
                resolve(result);
              }
            },
            () => {} // callback which fires when server has finished
          );
        });
      });
  }
}

module.exports = TSDDPClient;
