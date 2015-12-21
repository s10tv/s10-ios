import React, {
  AppRegistry,
  View,
  Text,
  Image,
  TouchableOpacity,
  PropTypes,
  StyleSheet,
  ScrollView,
  Dimensions
} from 'react-native';

import { connect } from 'react-redux/native';

import { SHEET, COLORS } from '../../CommonStyles';
import moment from 'moment';
require('moment-duration-format');
import Routes from '../../nav/Routes';
import Analytics from '../../../modules/Analytics';
import { renderEventCard } from './eventsCommon';

const logger = new (require('../../../modules/Logger'))('EventCountdownTimer');
const { width, height } = Dimensions.get('window');

function mapStateToProps(state) {
  return {
    nextMatchDate: state.nextMatchDate,
  }
}

class EventCountdownScreen extends React.Component {

  static propTypes = {
    timerStartDate: PropTypes.object.isRequired,
    event: PropTypes.object.isRequired
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

    let timerFunction = function() {
      let nextMatchDateSettings = self.props.timerStartDate;
      if (!nextMatchDateSettings) {
        return;
      }

      let formattedDate = moment.duration(nextMatchDateSettings - new Date()).format("H:mm:ss");
      this.setState({ countdown: formattedDate});
    }

    timerFunction.bind(this)();
    this.setState({ timer: setInterval(timerFunction.bind(this), 1000) })
  }

  render() {
    return (
      <View style={SHEET.container}>
        <ScrollView>
          { renderEventCard(this.props.event, null, true) }
          <View style={SHEET.innerContainer}>
            <View style={styles.timeLeftTillEventContainer}>
              <Text style={[SHEET.baseText, styles.timeLeftTillEventText]}> There is {this.state.countdown} until the start
                of this lovely event. Don’t forget to come! </Text>
            </View>
          </View>
        </ScrollView>
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
  timeLeftTillEventContainer: {
    backgroundColor: '7947B3',
    padding: 10,
    borderRadius: 3,
  },
  timeLeftTillEventText: {
    color: 'white',
    textAlign: 'center',
    fontSize: 18,
  },
});

export default connect(mapStateToProps)(EventCountdownScreen);
