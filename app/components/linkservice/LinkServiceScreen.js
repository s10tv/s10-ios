import React, {
  StyleSheet,
  WebView
} from 'react-native';

import { SCREEN_LINK_SERVICE } from '../../constants';
import Screen from '../Screen';

const logger = new (require('../../../modules/Logger'))('LinkServiceScreen');

class LinkServiceScreen extends Screen {

  static id = SCREEN_LINK_SERVICE;
  static leftButton = (route, router) => Screen.generateButton('Back', router.pop.bind(router));
  static rightButton = () => null
  static title = () => null

  render() {
    return (
      <WebView
        style={styles.webView}
        onNavigationStateChange={this.props.onServiceLinkNavStateChange}
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
