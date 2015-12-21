import React, {
  View,
  Text,
  ListView,
  TouchableOpacity,
  StyleSheet,
} from 'react-native';

import EventCountdownScreen from './EventCountdownScreen';
import SpeedIntros from './games/SpeedIntros';

import { connect } from 'react-redux/native';
import { SHEET, COLORS } from '../../CommonStyles';
import { TappableCard } from '../lib/Card';
import sectionTitle from '../lib/sectionTitle';
import Loader from '../lib/Loader';
import Routes from '../../nav/Routes';
import { renderEventCard } from './eventsCommon'

function mapStateToProps(state) {
  return {
    ddp: state.ddp,
    myCheckins: state.myCheckins,
  }
}

class EventListScreen extends React.Component {

  constructor(props = {}) {
    super(props);
    const ds = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
    this.state = {
      dataSource: ds.cloneWithRows(props.myCheckins),
      isLoading: true
    }
  }

  componentWillMount() {
    this.observer = this.props.ddp.collections.observe(() => {
      return this.props.ddp.collections.myevents.findOne({});
    }).subscribe(user => {
      if (user && user.checkins) {
        this.setState({
          dataSource: this.state.dataSource.cloneWithRows(user.checkins),
          isLoading: false
        })
      }
    });
  }

  componentWillUnmount() {
    if (this.observer) {
      this.observer.dispose()
    }
  }

  renderCheckin(checkin) {
    return renderEventCard(checkin, () => {
      const route = Routes.instance.getEventDetailScreen(checkin);
      this.props.navigator.push(route);
    });
  }

  render() {
    var eventList = this.state.isLoading ? <Loader /> :
      <ListView
        dataSource={this.state.dataSource}
        renderRow={(checkin) => { return this.renderCheckin(checkin) }}
      />
    return (
      <View style={SHEET.container}>
        <View style={SHEET.innerContainer}>
          { sectionTitle('CHECKED IN TO', { paddingTop: 10 }) }
          { eventList }
        </View>
      </View>
    )
  }
}

var styles = StyleSheet.create({

});

export default connect(mapStateToProps)(EventListScreen);
