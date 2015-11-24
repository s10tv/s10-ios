let React = require('react-native');
let { AsyncStorage } = React;

let DDPClient = require("ddp-client");
let _ = require('lodash');

let Digits = require('react-native-fabric-digits');
let { DigitsAuthenticateManager } = Digits;

let FBSDKLogin = require('react-native-fbsdklogin');
let { FBSDKLoginManager } = FBSDKLogin;

let Logger = require('./Logger');

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
    this.logger = new Logger(this);
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
    return new Promise((resolve, reject) => {
      this.ddpClient.connect((error, wasReconnect) => {
        // If autoReconnect is true, this back will be invoked each time
        // a server connection is re-established
        if (error) {
          return reject(error);
        }

        this.connected = true;
        this.__resolveBeforeInitPromises()

        this.logger.debug('DDP initialized');
        resolve(true);
      });
    });
  }

  isConnected() {
    return this.currentUserId && this.loggedIn;
  }

  __onLogin(res) {
    if (res) {
      this.loggedIn = true;
      this.currentUserId = res.id;
      this.__resolveBeforeLoginPromises();
    }
  }

  isLoggedIn() {
    return AsyncStorage.multiGet(['loginToken', 'userId'])
    .then(res => {
      let token = null;
      let userId = null;

      res.forEach(result => {
        if (result[0] == 'loginToken') {
          token = result[1];
        } else if (result[0] == 'userId') {
          userId = result[1];
        }
      })

      return Promise.resolve({ token, userId });
    })
  }

  loginWithToken(token) {
    if (token) {
      return new Promise((resolve, reject) => {
        this.ddpClient.call("login", [{ resume: token }], (err, res) => {
          if (err) {
            return resolve({});
          }

          this.__onLogin(res);
          this.logger.info(`logged in with ${token}`);
          resolve({
            userId: res.id,
            token: token,
          });
        });
      });
    } else {
      return Promise.resolve({})
    }
  }

  logout() {
    return this.call({ methodName: "logout"})
    .then(() => {
      AsyncStorage.multiRemove(['userId', 'loginToken']);
      DigitsAuthenticateManager.logout();
      FBSDKLoginManager.logOut();
      return Promise.resolve(true);
    })
    .catch(err => {
      this.loggger.error(JSON.stringify(err));
    })
  }

  close() {
    this.__resolveBeforeInitPromises();
    return this.ddpClient.close();
  }

  subscribe(options) {
    let { pubName, params, userRequired } = options;

    if (!pubName) {
      this.logger.error('Cannot subscribe to empty publication');
    }

    userRequired = userRequired || true;
    params = params || [];

    let userInSessionPromise = userRequired ?
      this.__waitForLogin() :
      Promise.resolve(true) ;

    return this.__waitForConnection()
      .then(() => userInSessionPromise)
      .then(() => {
        return new Promise((resolve, reject) => {
          let subId = this.ddpClient.subscribe(pubName, params, () => {
            this.logger.info(`subscribed ${pubName} >>> ${subId}`);
            return resolve(subId);
          });
        });
      })
      .catch(err => {
        this.loggger.error(JSON.stringify(err));
      })
  }

  unsubscribe(subId) {
    this.ddpClient.unsubscribe(subId);
  }

  call(options) {
    let { methodName, params } = options;

    if (!methodName) {
      this.loggger.error('Cannot call method without method name');
    }

    if (params && !_.isArray(params)) {
      this.loggger.warn('Params must be passed as an array to ddp.call');
    }

    return new Promise((resolve, reject) => {
      this.ddpClient.call(methodName, params,
        (err, result) => { // callback which returns the method call results
          if (err) {
            reject(err);
          } else {
            resolve(result);
          }
        },
        () => { // callback which fires when server has finished
          // console.log('updated');  // sending any updated documents as a result of
          // console.log(ddpclient.collections.posts);  // calling this method
        }
      );
    });
  }
}

module.exports = TSDDPClient;