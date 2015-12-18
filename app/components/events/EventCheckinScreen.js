import React, {
  AlertIOS,
  View,
  Text,
  TextInput,
  TouchableOpacity,
  ScrollView,
  StyleSheet,
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
        <View style={SHEET.innerContainer}>
          { sectionTitle('CHECKIN TO EVENT') }
          <ScrollView scrollable={false}>
            <Card>
              <TextInput
                placeholder={'Invite Code'}
                placeholderTextColor={COLORS.background}
                style={{height: 40, borderColor: COLORS.background, borderWidth: 1, padding: 10}}
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
                <Text style={styles.button}>Check In</Text>
              </TouchableOpacity>
            </View>
            </Card>
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
    marginTop: 10,
  },
  button: {
    color: COLORS.white,
    backgroundColor: COLORS.taylr,
    padding: 10,
    width: 100,
    textAlign: 'center',
  }
})

export default connect(mapStateToProps)(EventCheckinScreen);
