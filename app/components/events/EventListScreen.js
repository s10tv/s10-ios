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
import { SHEET, COLORS} from '../../CommonStyles';
import { TappableCard } from '../lib/Card';
import sectionTitle from '../lib/sectionTitle';
import Loader from '../lib/Loader';
import Routes from '../../nav/Routes';

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
      dataSource: ds.cloneWithRows(props.myCheckins)
    }
  }

  componentWillMount() {
    this.observer = this.props.ddp.collections.observe(() => {
      return this.props.ddp.collections.myevents.findOne({});
    }).subscribe(user => {
      if (user && user.checkins) {
        this.setState({
          dataSource: this.state.dataSource.cloneWithRows(user.checkins)
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
    return (
      <TappableCard key={checkin._id} onPress={() => {
        const route = Routes.instance.getEventDetailScreen(checkin);
        this.props.navigator.push(route)
      }}>
        <View>
          <Text>{ checkin.title }</Text>
          <Text>{ checkin.desc }</Text>
        </View>
      </TappableCard>
    )
  }

  render() {
    return (
      <View style={SHEET.container}>
        <ListView
          dataSource={this.state.dataSource}
          renderRow={(checkin) => { return this.renderCheckin(checkin) }}
        />
      </View>
    )
  }
}

export default connect(mapStateToProps)(EventListScreen);
