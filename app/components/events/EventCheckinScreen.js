import React, {
  AlertIOS,
  View,
  Text,
  TextInput,
  TouchableOpacity,
  ScrollView,
  StyleSheet,
  Image,
  ActivityIndicatorIOS
} from 'react-native';

import { connect } from 'react-redux/native';
import { SHEET, COLORS} from '../../CommonStyles';
import { Card } from '../lib/Card';
import sectionTitle from '../lib/sectionTitle';
import Routes from '../../nav/Routes';
const logger = new (require('../../../modules/Logger'))('EventCheckinScreen');
function mapStateToProps(state) {
  return {
    ddp: state.ddp,
  }
}

class EventCheckinScreen extends React.Component {

  constructor(props = {}) {
    super(props);
    this.state = {
      isJoining: false
    }
  }

  render() {
    var joinButtonContents = this.state.isJoining ?
      <ActivityIndicatorIOS
        style={styles.isJoiningActivityIndicator}
        size='small'
        color='white'
        animating={this.state.isLoading}/> :
      <Text style={[SHEET.baseText, styles.joinButtonText]}>Join</Text>

    return (
      <View style={SHEET.container}>
        <View style={[SHEET.innerContainer, { flex: 1 }]}>
          <ScrollView scrollable={false}>
          { sectionTitle('JOIN EVENT') }
            <Card hideSeparator={true} style={styles.joinEventCard} cardOverride={{ padding: 10 }}>
              <TextInput
                placeholder={'Enter Invite Code'}
                placeholderTextColor={COLORS.background}
                style={[SHEET.baseText, styles.inviteCodeTextInput]}
                onChangeText={(text) => this.setState({text})}
                value={this.state.text}
             />

             <View style={styles.actions}>
               <TouchableOpacity style={styles.buttonContainer} onPress={() => {
                 if (this.state.text == null) {
                   AlertIOS.alert('Oops.', 'It seems that you forgot to enter the code.');
                 } else {
                   this.setState({ isJoining: true });
                   this.props.ddp.call({
                     methodName: 'events/join',
                     params: [this.state.text]
                   })
                   .then(res => {
                     const event = res;
                     this.setState({ isJoining: false });
                     const route = Routes.instance.getEventDetailScreen(event);
                     this.props.navigator.push(route);
                   })
                   .catch(err => {
                     logger.debug(err.message);
                     this.setState({ isJoining: false });
                     AlertIOS.alert('Oops.', err.reason);
                   })
                 }
               }}>
               <View style={styles.button}>
                { joinButtonContents }
               </View>
              </TouchableOpacity>
            </View>
            </Card>
            <Text style={[SHEET.baseText, styles.headerReminderText]}>
              Find the invite code at the entrance to join the event.
            </Text>
            <Image source={require('../img/ic-event-poster.png')} style={styles.eventPoster} />
          </ScrollView>
        </View>
      </View>
    )
  }
}

var styles = StyleSheet.create({
  actions: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'flex-end',
  },
  buttonContainer: {
    flex: 1,
    marginTop: 10,
  },
  button: {
    backgroundColor: COLORS.taylr,
    padding: 10,
  },
  inviteCodeTextInput: {
    borderColor: COLORS.background,
    borderWidth: 1,
    padding: 10,
    height: 40,
  },
  joinEventCard: {
    borderRadius: 3,
    padding: 1
  },
  headerReminderText: {
    marginTop: 17,
    fontSize: 18,
    color: '#4A4A4A',
    textAlign: 'center',
    paddingHorizontal: 40,
  },
  eventPoster: {
    width: 149,
    height: 208,
    marginTop: 17,
    alignSelf: 'center',
  },
  joinButtonText: {
    textAlign: 'center',
    fontSize: 16,
    color: COLORS.white,
  },
  isJoiningActivityIndicator: {
    alignSelf: 'center'
  },
})

export default connect(mapStateToProps)(EventCheckinScreen);
