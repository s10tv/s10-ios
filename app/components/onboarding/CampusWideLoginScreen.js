import React, {
  WebView,
  PropTypes,
  StyleSheet,
} from 'react-native';

import { connect } from 'react-redux/native';
import CookieManager from 'react-native-cookies';

import { SCREEN_OB_CWL_LOGIN } from '../../constants';
import Loader from '../lib/Loader';
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

  static propTypes = {
    navigator: PropTypes.object.required,
  }

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

          const route = Router.instance.getLinkServiceRoute();
          this.props.navigator.push(route);
        }
      })
    }
  }

  render() {
    const url = 'https://cas.id.ubc.ca/ubc-cas/login';

    if (!this.props.navigator) {
      return <Loader />
    }

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
