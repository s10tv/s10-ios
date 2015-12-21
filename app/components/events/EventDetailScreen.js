import React, {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  StyleSheet,
  Dimensions,
  Image
} from 'react-native';

import EventCountdownScreen from './EventCountdownScreen';
import SpeedIntros from './games/SpeedIntros';

import { connect } from 'react-redux/native';
import { SHEET, COLORS} from '../../CommonStyles';
import { TappableCard } from '../lib/Card';
import sectionTitle from '../lib/sectionTitle';
import Loader from '../lib/Loader';
import Routes from '../../nav/Routes';
import { renderEventCard } from './eventsCommon'
import { renderReasonSection } from '../discover/renderReasonSection';
import iconTextRow from '../lib/iconTextRow';

const logger = new (require('../../../modules/Logger'))('EventDetailScreen');
const { width, height } = Dimensions.get('window');

function mapStateToProps(state) {
  return {
    me: state.me,
    ddp: state.ddp,
  }
}

class EventDetailScreen extends React.Component {

  constructor(props = {}) {
    super(props);
    this.state = {}
  }

  componentWillMount() {
    this.props.ddp.subscribe({ pubName: 'speedintro-event', params: [this.props.event._id] })
    .then((subId) => {
      this.subId = subId;

      this.observer = this.props.ddp.collections.observe(() => {
        return this.props.ddp.collections.speedintros.find({ type: 'active' });
      }).subscribe(intros => {
        if (intros.length > 0) {
          const [currentIntro] = intros;

          currentIntro.user = this.props.ddp._formatUser(currentIntro.user);
          this.setState({ currentIntro: currentIntro });
        }
      });
    })
  }

  componentWillUnmount() {
    if (this.subId) {
      this.props.ddp.unsubscribe(this.subId);
    }

    if (this.observer) {
      this.observer.dispose()
    }
  }

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
        if (event.startTime > new Date()) {
          return <EventCountdownScreen event={event} title={event.title} timerStartDate={event.startTime} />
        }

        var candidateCard = <Loader />

        if (this.state.currentIntro) {
          logger.debug(JSON.stringify(this.state.currentIntro));
          const intro = this.state.currentIntro;
          const user = intro.user;

          candidateCard = (
            <View>
              <TappableCard style={styles.card}
                  onPress={() => {
                    const route = Routes.instance.getProfileRoute({
                      user: user,
                      isEditable: false,
                    });

                    this.props.navigator.parentNavigator.push(route);
                  }}
                  cardOverride={{padding: 10}}
                  hideSeparator={true}>
                <View style={{ flexDirection: 'column' }}>
                  <View style={{ flexDirection: 'row' }}>
                    <Image source={{ uri: user.avatarUrl }} style={styles.avatar} />
                    <View style={styles.userInfo}>
                      <Text style={[SHEET.baseText, styles.displayNameText]}>{user.displayName}</Text>
                      {iconTextRow(require('../img/ic-mortar.png'), user.major, styles.userIconTextRow)}
                      {iconTextRow(require('../img/ic-house.png'), user.hometown, styles.userIconTextRow)}
                    </View>
                  </View>

                  <View style={styles.inCommonAndSeparatorContainer}>
                    <Text style={[SHEET.baseText, styles.inCommonText]}>In common:</Text>
                    <View style={[SHEET.separator, styles.separator]} />
                  </View>

                  { renderReasonSection(this.props.me, user, { paddingHorizontal: 0 }) }
                  <View style={SHEET.separator}/>

                  <View style={styles.candidateCardDetailContainer}>
                    <Image source={require('../img/ic-die-dark.png')} style={styles.dieIcon}/>
                    <Text style={[SHEET.baseText, styles.introPromptText]} numberOfLines={5}>feliciatin</Text>
                  </View>

                  <View style={styles.candidateCardDetailContainer}>
                    <Image source={require('../img/ic-pin-dark.png')} style={styles.pinIcon}/>
                    <Text style={[SHEET.baseText, styles.introLocationText]}>Station 1A</Text>
                  </View>
                </View>
              </TappableCard>
              <View style={styles.goFindSomeoneContainer}>
                <Text style={[SHEET.baseText, styles.goFindSomeoneText]}> Go find {user.firstName}! You still have x. </Text>
              </View>
            </View>
          )
        }

        return (
          <View style={SHEET.container}>
            <ScrollView>
              { renderEventCard(event, null, true) }
              <View style={SHEET.innerContainer}>
                { sectionTitle('CURRENT CANDIDATE') }
                { candidateCard }
              </View>
            </ScrollView>
          </View>
        );
    }

    return <View />
  }
}

var styles = StyleSheet.create({
  avatar: {
    width: width / 5,
    height: width / 5,
    borderRadius: width / 10,
  },
  userInfo: {
    flex: 1,
    flexDirection: 'column',
    marginLeft: 10,
  },
  userIconTextRow: {
    padding: 0,
    marginTop: 7,
  },
  card: {
    marginTop: 8,
    borderRadius: 3,
    padding: 1,
  },
  displayNameText: {
    fontSize: 16,
  },
  inCommonText: {
    fontSize: 14,
  },
  separator: {
    flex: 1,
    marginTop: 3,
    alignSelf: 'center',
    marginLeft: 10,
  },
  inCommonAndSeparatorContainer: {
    flex: 1,
    flexDirection: 'row',
    marginTop: 10,
  },
  candidateCardDetailContainer: {
    flexDirection: 'row',
    marginTop: 10,
  },
  dieIcon: {
    width: 14,
    height: 14,
    alignSelf: 'center',
  },
  pinIcon: {
    width: 12,
    height: 18,
    marginLeft: 1,
    alignSelf: 'center',
  },
  introPromptText: {
    marginLeft: 10,
    fontSize: 14,
    width: width / 1.2,
  },
  introLocationText: {
    marginLeft: 10,
    fontSize: 14,
  },
  goFindSomeoneContainer: {
    backgroundColor: '7947B3',
    padding: 10,
    borderRadius: 3,
  },
  goFindSomeoneText: {
    color: 'white',
    textAlign: 'center',
    fontSize: 20,
  }
})

export default connect(mapStateToProps)(EventDetailScreen);
