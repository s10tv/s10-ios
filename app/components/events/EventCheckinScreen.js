import React, {
  AlertIOS,
  View,
  Text,
  TextInput,
  TouchableOpacity,
  ScrollView,
  StyleSheet,
  Image
} from 'react-native';

import { connect } from 'react-redux/native';
import { SHEET, COLORS} from '../../CommonStyles';
import { Card } from '../lib/Card';
import sectionTitle from '../lib/sectionTitle';

function mapStateToProps(state) {
  return {
    ddp: state.ddp,
  }
}

class EventCheckinScreen extends React.Component {

  constructor(props = {}) {
    super(props);
    this.state = {}
  }

  render() {
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
                 this.props.ddp.call({
                   methodName: 'events/join',
                   params: [this.state.text]
                 })
                 .catch(err => {
                   AlertIOS.alert('Hmm', err.reason)
                 })
               }}>
                <Text style={[SHEET.baseText, styles.button]}>Join</Text>
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
    color: COLORS.white,
    backgroundColor: COLORS.taylr,
    padding: 10,
    textAlign: 'center',
    fontSize: 16,
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
  }
})

export default connect(mapStateToProps)(EventCheckinScreen);
