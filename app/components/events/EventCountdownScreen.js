import React, {
  AppRegistry,
  View,
  Text,
  Image,
  TouchableOpacity,
  PropTypes,
  StyleSheet,
} from 'react-native';

import { connect } from 'react-redux/native';

import { SHEET, COLORS } from '../../CommonStyles';
import Routes from '../../nav/Routes';
import Analytics from '../../../modules/Analytics';

const logger = new (require('../../../modules/Logger'))('CountdownTimer');

function mapStateToProps(state) {
  return {
    nextMatchDate: state.nextMatchDate,
  }
}

class EventCountdownScreen extends React.Component {

  static propTypes = {
    timerEndDate: PropTypes.object.isRequired,
  }

  constructor(props) {
    super(props);
    this.state = {
      countdown: ''
    }
  }

  componentWillUnmount() {
    clearTimeout(this.state.timer);
  }

  componentWillMount() {
    const self = this;

    if (this.props.overrideText) {
      this.setState({ countdown: this.props.overrideText });
      return;
    }

    let format = function(num) {
      return ("0" + num).slice(-2);
    }

    let timerFunction = function() {
      let nextMatchDateSettings = self.props.timerEndDate;
      if (!nextMatchDateSettings) {
        return;
      }

      let nextMatchDate = Math.floor(nextMatchDateSettings.getTime() / 1000);
      let now = Math.floor(new Date().getTime() / 1000);

      let interval = Math.max(nextMatchDate - now, 0)
      let hours = Math.floor(interval / 3600);
      let minutes = Math.floor((interval - hours * 3600) / 60);
      let seconds = Math.floor((interval - hours * 3600) - minutes * 60);

      this.setState({ countdown: `${format(hours)}:${format(minutes)}:${format(seconds)}`});
    }

    timerFunction.bind(this)();
    this.setState({ timer: setInterval(timerFunction.bind(this), 1000) })
  }

  render() {
    return (
      <View style={[styles.messageButton, this.props.style]}>
        <Text style={[{ color: COLORS.background, fontSize: 24, marginBottom: 10 }, SHEET.baseText]}>
          {this.props.title}
        </Text>
        <Text style={[styles.messageButtonText, SHEET.baseText]}>
          { this.state.countdown }
        </Text>
      </View>
    )
  }
}

var styles = StyleSheet.create({
  messageButton: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  messageButtonText: {
    fontSize: 18,
    color: COLORS.taylr,
  },
});

export default connect(mapStateToProps)(EventCountdownScreen);
