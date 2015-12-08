import React, {
  StyleSheet,
  WebView
} from 'react-native';

import { connect } from 'react-redux/native';
import CookieManager from 'react-native-cookies';

import { SCREEN_OB_CWL_LOGIN } from '../../constants';
import Screen from '../Screen';
import Router from '../../nav/Routes'

const logger = new (require('../../../modules/Logger'))('LinkServiceScreen');

function mapStateToProps(state) {
  return {
    ddp: state.ddp,
  }
}

class CampusWideLoginScreen extends Screen {

  static id = SCREEN_OB_CWL_LOGIN;
  static leftButton = (route, router) => Screen.generateButton('Back', router.pop.bind(router));
  static rightButton = () => null
  static title = () => null

  onCWLLoginNavStateChange(navState) {
    const cookieName = 'CASTGC';

    if (!navState.loading && navState.title.length > 0) {
      logger.info('handling onCWLLoginNavStateChange');

      CookieManager.getAll((cookies, res) => {
        if (cookies && cookies[cookieName]) {
          this.props.ddp.call({
            methodName: 'network/join',
            params: [cookies[cookieName].value]
          });

          const route = Router.instance.getMainNavigatorRoute();
          const navigator = this.props.navigator;
          this.props.navigator.parentNavigator.push(route);
        }
      })
    }
  }

  render() {
    const url = 'https://cas.id.ubc.ca/ubc-cas/login';

    return (
      <WebView
        style={styles.webView}
        onNavigationStateChange={this.onCWLLoginNavStateChange.bind(this)}
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

export default connect(mapStateToProps)(CampusWideLoginScreen)
