import React, {
  StyleSheet,
  Component,
  View,
  Text,
  TouchableOpacity
} from 'react-native';

import { connect } from 'react-redux/native';
import Session from '../native_modules/Session';

const logger = new (require('../modules/Logger'))('LayoutContainer');

class LayoutContainer extends React.Component {

  componentWillMount() {
    this._setUpDDP()
  }

  async _setUpDDP() {
    logger.debug('setting up ddp ... ');
    new ResumeTokenHandler(this.props.ddp, Session).handle(this.props.dispatch);
  }

  render() {
    if (this.props.loggedIn) {
      return (
        <View style={{ paddingTop: 50 }}>
          <Text>Logged in!</Text>
        </View>
      )
    }

    return (
      <View style={{ paddingTop: 50 }}>
        <Text>Not Logged In</Text>
      </View>
    )
  }
}

function mapStateToProps(state) {
  return {
    counter: state.counter,
    loggedIn: state.loggedIn,
  }
}

export default connect(mapStateToProps)(LayoutContainer)
