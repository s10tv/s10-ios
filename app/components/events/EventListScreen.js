import React, {
  View,
  Text,
  ListView,
  TouchableOpacity,
  StyleSheet,
  Image
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

const logger = new (require('../../../modules/Logger'))('EventListScreen');

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
      isLoading: true,
      isEventListEmpty: false,
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
        if (user.checkins.length == 0) {
          this.setState({
            isLoading: false,
            isEventListEmpty: true
          })
        }
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
    var eventListView;

    if (this.state.isLoading) {
      eventListView = <Loader />
    } else if (this.state.isEventListEmpty) {
      eventListView =
      <View style={styles.emptyStateContainer}>
        <Image source={require('../img/lonely-man.png')} style={styles.emptyStateImage} />
        <Text style={[styles.emptyStateText, SHEET.baseText]}>
          Don't be a loner. Come to an event and we will show it here!
        </Text>
      </View>
    } else {
      eventListView =
      <View style={SHEET.innerContainer}>
        { sectionTitle('CHECKED IN TO', { paddingTop: 10}) }
        <ListView
          dataSource={this.state.dataSource}
          renderRow={(checkin) => { return this.renderCheckin(checkin) }}
        />
      </View>
    }

    return (
      <View style={SHEET.container}>
        { eventListView }
      </View>
    )
  }
}

var styles = StyleSheet.create({
  emptyStateContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  emptyStateImage: {
    width: 102,
    height: 200,
    resizeMode: 'contain',
  },
  emptyStateText: {
    fontSize: 20,
    marginTop: 20,
    paddingHorizontal: 30,
    color: COLORS.attributes,
    textAlign: 'center',
  }
});

export default connect(mapStateToProps)(EventListScreen);
