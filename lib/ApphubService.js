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

        store.dispatch({
          visible: true,
          type: 'DISPLAY_POPUP_MESSAGE',
          dialog: {
            title: 'New version available',
            message: "It's awesome and we think you should give it a try.",
            actionKey: 'APPHUB_INSTALL'
          }
        })
      });
  }
}

export default ApphubService;
