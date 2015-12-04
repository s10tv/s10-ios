import React, {
  StyleSheet,
  Component,
  View,
  Text,
  TouchableOpacity
} from 'react-native';

// external dependencies
import { connect } from 'react-redux/native';

// internal dependencies
import LoginScreen from './components/onboarding/LoginScreen'
import RootNavigator from './RootNavigator';
import Session from '../native_modules/Session';
import ResumeTokenHandler from './util/ResumeTokenHandler'

const logger = new (require('../modules/Logger'))('LayoutContainer');

class LayoutContainer extends React.Component {

  componentWillMount() {
    this._setUpDDP()
  }

  _setUpDDP() {
    logger.debug('setting up ddp ... ');
    new ResumeTokenHandler(this.props.ddp, Session).handle(this.props.dispatch);
  }

  render() {
    logger.debug(`Rendering layout. loggedIn=${this.props.loggedIn}`)

    if (!this.props.loggedIn) {
      return (
        <LoginScreen />
      )
    }

    return (
      <RootNavigator
        style={{ flex: 1 }}
        sceneStyle={{ paddingTop: 64 }} />
    )
  }
}

function mapStateToProps(state) {
  return {
    ddp: state.ddp,
    loggedIn: state.loggedIn,
  }
}

export default connect(mapStateToProps)(LayoutContainer)
