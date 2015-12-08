import React, {
  StyleSheet,
  WebView
} from 'react-native';

import { SCREEN_LINK_SERVICE } from '../../constants';
import Screen from '../Screen';
import BridgeManager from '../../../modules/BridgeManager';

const logger = new (require('../../../modules/Logger'))('LinkServiceScreen');

class LinkServiceScreen extends Screen {

  static id = SCREEN_LINK_SERVICE;
  static leftButton = (route, router) => Screen.generateButton('Back', router.pop.bind(router));
  static rightButton = () => null
  static title = () => null

  /**
   * Determines when to close the service link card.
   */
  _onServiceLinkNavStateChange(navState) {
    if (navState.url.indexOf(BridgeManager.bundleUrlScheme()) != -1) {
      this.router.pop()
    }
  }

  render() {
    return (
      <WebView
        style={styles.webView}
        onNavigationStateChange={this.props._onServiceLinkNavStateChange}
        startInLoadingState={true}
        url={this.props.url} />
    )
  }
}

let styles = StyleSheet.create({
  webView: {
  },
})

export default LinkServiceScreen;
