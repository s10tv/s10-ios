let React = require('react-native');
let Button = require('react-native-button');

let {
  AppRegistry,
  View,
  Text,
  Image,
  StyleSheet,
} = React;

let SHEET = require('../CommonStyles').SHEET;
let COLORS = require('../CommonStyles').COLORS;
let Analytics = require('../../modules/Analytics');

class CountdownTimer extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      countdown: '...'
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
    let format = function(num) {
      return ("0" + num).slice(-2);
    }

    let timerFunction = function() {
      let settings = this.props.settings;
      if (!settings || !settings.nextMatchDate) {
        return;
      }

      let nextMatchDate = Math.floor(settings.nextMatchDate.value.getTime() / 1000);
      let now = Math.floor(new Date().getTime() / 1000);

      let interval = Math.max(nextMatchDate - now, 0)
      let hours = Math.floor(interval / 3600);
      let minutes = Math.floor((interval - hours * 3600) / 60);
      let seconds = Math.floor((interval - hours * 3600) - minutes * 60);

      this.setState({ countdown: `${format(hours)}:${format(minutes)}:${format(seconds)}`});
    }

    if (!this.props.text) {
      timerFunction.bind(this)();
      this.setState({ timer: setInterval(timerFunction.bind(this), 1000) })
    } else {
      this.setState({ countdown: this.props.text });
    }
  }

  render() {
    return (
      <Button
        onPress={() => {
          Analytics.track('Today: Tap Message');

          let user = this.formatUser(this.props.candidateUser);
          let currentUser = this.formatUser(this.props.me);

          this.props.navigator.push({
            id: 'sendMessage',
            currentUser: currentUser,
            recipientUser: user,
          })
        }}>
        <View style={[styles.messageButton, this.props.style]}>
          <Image source={require('../img/ic-start-chat.png')} />
          <Text style={[styles.messageButtonText, SHEET.baseText]}>
            { this.state.countdown }
          </Text>
        </View>
      </Button>
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

module.exports = CountdownTimer;
