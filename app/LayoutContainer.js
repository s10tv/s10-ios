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

    try {
      await this.props.ddp.initialize()

      if (!this.props.ddp.connected) {
        logger.warning('Cannot connect to DDP server.');
        return;
      }

      if (Session.initialValue) {
        const { userId, resumeToken } = Session.initialValue;

        this.props.dispatch({
          type: 'LOGIN_FROM_RESUME',
          userId,
          resumeToken,
        });

        const loginResult = await this.props.ddp.loginWithToken(resumeToken);

        if (loginResult.resumeToken == resumeToken) {
          // The user has logged in successfully
          return this.props.ddp.subscribe();
        } else {
          // TODO(qimingfang): the user did not log in successfully.
        }
      }
    } catch (err) {
      logger.error(err);
    }
  }

  render() {
    return (
      <View style={{ paddingTop: 50 }}>
        <TouchableOpacity onPress={() => {
          this.props.dispatch({
            type: 'INCREMENT_COUNTER'
          })
        }}>
          <View><Text>Increase</Text></View>

        </TouchableOpacity>
        <Text>{ this.props.counter }</Text>
      </View>
    )
  }
}

function mapStateToProps(state) {
  return {
    counter: state.counter,
    currentAccount: state.currentAccount,
  }
}

export default connect(mapStateToProps)(LayoutContainer)
