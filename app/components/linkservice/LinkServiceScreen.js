import React, {
  StyleSheet,
  WebView
} from 'react-native';

import BridgeManager from '../../../modules/BridgeManager';

const logger = new (require('../../../modules/Logger'))('LinkServiceScreen');

class LinkServiceScreen extends React.Component {

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
    paddingTop: 64,
  },
})

export default LinkServiceScreen;
