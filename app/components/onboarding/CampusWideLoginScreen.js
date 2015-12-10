import React, {
  WebView,
  PropTypes,
  StyleSheet,
} from 'react-native';

import { connect } from 'react-redux/native';
import CookieManager from 'react-native-cookies';
import FechUBCClasses from 'ubc-classes';

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
    onFinishedCWL: PropTypes.func.required,
  }

  onCWLLoginNavStateChange(navState) {
    const CASTGC = 'CASTGC';
    const JSESSIONID = 'JSESSIONID';
    const csjdk6 = 'csjdk6';

    if (!navState.loading && navState.title.length > 0) {
      logger.info('handling onCWLLoginNavStateChange');

      CookieManager.getAll((cookies, res) => {
         if (cookies && cookies[CASTGC] && cookies[JSESSIONID] && cookies[csjdk6]) {
           this.props.onFinishedCWL();
         }
      })
    }
  }

  render() {
    const url = 'https://cas.id.ubc.ca/ubc-cas/login?TARGET=https%3A%2F%2F' +
      'courses.students.ubc.ca%2Fcs%2Fsecure%2Flogin%3' +
      'FIMGSUBMIT.x%3D29%26IMGSUBMIT.y%3D3%26IMGSUBMIT%3DIMGSUBMIT';

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
