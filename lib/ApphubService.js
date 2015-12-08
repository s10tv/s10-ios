import {
  NativeAppEventEmitter,
  NativeModules,
} from 'react-native';

const logger = new (require('../modules/Logger'))('ApphubService');

class ApphubService {
  listen(store) {
    logger.debug('Apphub service started');

    this.allListener = NativeAppEventEmitter
      .addListener('AppHub.newBuild', (details) => {
        logger.debug(`Got new apphub build. details=${JSON.stringify(details)}`)
        store.dispatch({ type: 'UPDATE_APPHUB_DETAILS', details: details })
      });
  }
}

export default ApphubService;
