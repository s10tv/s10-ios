import {
  NativeAppEventEmitter,
  NativeModules,
} from 'react-native';

import BridgeManager from '../modules/BridgeManager';

const logger = new (require('../modules/Logger'))('PushHandler');

class PushHandler {

  listen(store, ddp) {
    logger.debug('push token handling service started');
    
    NativeAppEventEmitter.addListener('RegisteredPushToken', (tokenInfo) => {
      logger.debug(`Did receive RegisteredPushToken. ${JSON.stringify(tokenInfo)}`);

      if (!tokenInfo) {
        logger.warning('Register push token called with no token');
        return;
      }

      tokenInfo.appId = BridgeManager.appId();
      tokenInfo.version = BridgeManager.version();
      tokenInfo.build = BridgeManager.build();
      tokenInfo.deviceId = BridgeManager.deviceId();
      tokenInfo.deviceName = BridgeManager.deviceName();

      logger.debug(`Will call device/update/push with ${JSON.stringify(tokenInfo)}`);

      ddp.call({ methodName: 'device/update/push', params: [tokenInfo] })
      .then(() => {
        logger.debug('Registered Push Token');
      })
      .catch(err => {
        logger.error(err);
      })
    });
  }
}

export default PushHandler;
