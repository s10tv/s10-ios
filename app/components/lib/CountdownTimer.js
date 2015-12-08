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

class CountdownTimer extends React.Component {

  static propTypes = {
    nextMatchDate: PropTypes.object.isRequired,
    candidateUser: PropTypes.object.isRequired,
    navigator: PropTypes.object.isRequired,
  }

  constructor(props) {
    super(props);
    this.state = {
      countdown: ''
    }
  }

  formatUser(candidateUser) {
    let coverUrl = candidateUser.cover ? candidateUser.cover.url :
      candidateUser.avatar.url;

    return {
      userId: candidateUser._id,
      avatarUrl: candidateUser.avatar.url,
      coverUrl: coverUrl,
      firstName: candidateUser.firstName,
      displayName: candidateUser.firstName,
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
      let nextMatchDateSettings = self.props.nextMatchDate;
      if (!nextMatchDateSettings) {
        logger.debug(`nextMatchDate: ${nextMatchDateSettings}`)
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
      <TouchableOpacity
        onPress={() => {
          Analytics.track('Tap Send Message');

          let recipientUser = this.props.candidateUser;
          logger.debug(`getSendMessageToUserRoute to ${JSON.stringify(recipientUser)}`)

          const route = Routes.instance.getSendMessageToUserRoute(recipientUser);
          this.props.navigator.parentNavigator.push(route);
        }}>
        <View style={[styles.messageButton, this.props.style]}>
          <Image source={require('../img/ic-start-chat.png')} />
          <Text style={[styles.messageButtonText, SHEET.baseText]}>
            { this.state.countdown }
          </Text>
        </View>
      </TouchableOpacity>
    )
  }
}

var styles = StyleSheet.create({
  messageButton: {
    height: 50,
    justifyContent: 'center',
    alignItems: 'center',
    flexDirection: 'row',
    marginHorizontal: 10,
    backgroundColor: COLORS.button,
    marginBottom: 10,
    borderRadius : 3,
  },
  messageButtonText: {
    paddingLeft: 5,
    fontSize: 18,
    color: COLORS.white,
  },
});

export default connect(mapStateToProps)(CountdownTimer);
