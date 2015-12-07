import React, {
  StyleSheet,
  WebView
} from 'react-native';

import { SCREEN_OB_CWL_LOGIN } from '../../constants';
import Screen from '../Screen';

const logger = new (require('../../../modules/Logger'))('LinkServiceScreen');

class CampusWideLoginScreen extends Screen {

  static id = SCREEN_OB_CWL_LOGIN;
  static leftButton = (route, router) => Screen.generateButton('Back', router.pop.bind(router));
  static rightButton = () => null
  static title = () => null

  render() {
    const url = 'https://cas.id.ubc.ca/ubc-cas/login';

    return (
      <WebView
        style={styles.webView}
        onNavigationStateChange={this.props.onCWLLoginNavStateChange}
        startInLoadingState={true}
        url={url} />
    )
  }
}

let styles = StyleSheet.create({
  webView: {
    paddingTop: 64,
  },
})

export default CampusWideLoginScreen;
