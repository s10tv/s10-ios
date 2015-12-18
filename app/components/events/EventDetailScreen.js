import React, {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  StyleSheet,
} from 'react-native';

import EventCountdownScreen from './EventCountdownScreen';
import SpeedIntros from './games/SpeedIntros';

import { connect } from 'react-redux/native';
import { SHEET, COLORS} from '../../CommonStyles';
import { Card } from '../lib/Card';
import sectionTitle from '../lib/sectionTitle';
import Loader from '../lib/Loader';
import Routes from '../../nav/Routes';

function mapStateToProps(state) {
  return {
    ddp: state.ddp,
  }
}

class EventDetailScreen extends React.Component {

  render() {
    const event = this.props.event;
    if (!event) {
      return <Loader />
    }

    switch(event.status) {
      case 'pending':
      case 'expired':
        return <View />; // TODO

      case 'active':
        // event has not started
        if (event.startTime < new Date()) {
          return <EventCountdownScreen title={event.title} timerEndDate={event.endTime} />
        }

        // event has started - can join now
        return (
          <View style={styles.center}>
            <TouchableOpacity onPress={() => {
              const route = Routes.instance.getSpeedIntrosRoute(event)
              this.props.navigator.push(route);
            }}>
              <Text style={styles.eventTitle}>{ event.title }</Text>
            </TouchableOpacity>
          </View>
        );
    }

    return <View />
  }
}

var styles = StyleSheet.create({
  eventTitle: {
    fontSize: 20,
    color: COLORS.taylr,
  },
  center: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  }
})

export default connect(mapStateToProps)(EventDetailScreen);
