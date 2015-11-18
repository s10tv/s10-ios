let React = require('react-native');
let { AsyncStorage } = React;

let DDPClient = require("ddp-client");
let _ = require('lodash');

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
    return new Promise((resolve, reject) => {
      this.ddpClient.connect((error, wasReconnect) => {
        // If autoReconnect is true, this back will be invoked each time
        // a server connection is re-established
        if (error) {
          return reject(error);
        }

        this.connected = true;
        this.__resolveBeforeInitPromises()

        console.log('DDP initialized');
        resolve(true);
      });
    });
  }

  isConnected() {
    return this.currentUserId && this.loggedIn;
  }

  loginWithToken(token) {
    return new Promise((resolve, reject) => {
      this.ddpClient.call("login", [{ resume: token }], (err, res) => {
        let obj = {
          loggedIn: true,
          userId: res.id
        };

        if (res) {
          this.currentUserId = res.id;
          this.loggedIn = true;
          this.__resolveBeforeLoginPromises();
        } else {
          obj.loggedIn = false
        }
        console.log(obj);
        resolve(obj);
      });
    });
  }

  close() {
    this.__resolveBeforeInitPromises();
    return this.ddpClient.close();
  }

  subscribe(options) {
    let { pubName, params, userRequired } = options;

    if (!pubName) {
      console.error('Cannot subscribe to empty publication');
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
            console.log(`subscribed ${pubName} >>> ${subId}`);
            return resolve(subId);
          });
        });
      });
  }

  unsubscribe(subId) {
    this.ddpClient.unsubscribe(subId);
  }

  call(options) {
    let { methodName, params } = options;

    if (!methodName) {
      console.error('Cannot call method without method name');
    }

    if (params && !_.isArray(params)) {
      console.warn('Params must be passed as an array to ddp.call');
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