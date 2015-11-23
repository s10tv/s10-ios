let React = require('react-native');
let Button = require('react-native-button');

let {
  AppRegistry,
  View,
  ScrollView,
  Text,
  Image,
  TouchableOpacity,
  StyleSheet,
} = React;

let GridView = require('react-native-grid-view');
let Dimensions = require('Dimensions');
let { width, height } = Dimensions.get('window');

let SHEET = require('../CommonStyles').SHEET;
let COLORS = require('../CommonStyles').COLORS;

let Loader = require('../lib/Loader');
let TappableCard = require('../lib/Card').TappableCard;

class HistoryScreen extends React.Component {

  // TODO: COPY/PASTE alert. From Activities
  _timeDifference(current, previous) {
    var msPerMinute = 60 * 1000;
    var msPerHour = msPerMinute * 60;
    var msPerDay = msPerHour * 24;
    var msPerWeek = msPerDay * 7;

    var elapsed = current - previous;

    if (elapsed < msPerHour) {
      return Math.round(elapsed/msPerMinute) + 'm';
    }

    else if (elapsed < msPerDay ) {
      return Math.round(elapsed/msPerHour ) + 'h';
    }

    else if (elapsed < msPerWeek) {
      return Math.round(elapsed/msPerDay) + 'd';
    }

    else {
      return Math.round(elapsed/msPerWeek) + 'w';
    }
  }


  renderHistory(candidate) {
    let user = this.props.ddp.collections.users.findOne({ _id: candidate.userId });
    if (user) {
      return (
        <TappableCard
          style={{ margin: 2 }}
          cardOverride={{ padding: 0 }}
          onPress={() => { this.props.navigator.push({
            id: 'viewprofile',
            me: user
          }) }}>
          <Image style={{ height: 150, flex: 1, imageResize: 'stretch' }} source={{ uri: user.avatar.url }} />
          <View style={{ flex: 1, flexDirection: 'row', padding: 10 }}>
            <Text style={[SHEET.baseText, { flex: 1 }]}>{user.firstName}</Text>
            <Text style={[{ width: 50, textAlign: 'right' }, SHEET.subTitle]}>{this._timeDifference(new Date(), candidate.date)}</Text>
          </View>
        </TappableCard>
      )
    }

    return null;
  }

  render() {
    let history = this.props.history;
    if (!history) {
      return <Loader />
    }

    let historyView = null;
    if (history.length == 0) {
      historyView = (
        <View style={styles.emptyStateContainer}>
          <Text style={[styles.emptyStateText, SHEET.baseText]}>
            You will see previous intros here.
          </Text>
        </View>
      )
    } else {
      history.sort((one, two) => { return  two.date - one.date })
      historyView = (
        <GridView
          items={history}
          itemsPerRow={2}
          renderItem={this.renderHistory.bind(this)} />
      )
    }

    return (
      <View style={SHEET.container}>
        <View style={[SHEET.innerContainer, SHEET.navTop]}>
          {historyView}
        </View>
      </View>
    )
  }
}

var styles = StyleSheet.create({
  emptyStateContainer: {
    flex: 1,
    height: height,
    justifyContent: 'center',
    alignItems: 'center',
  },
  emptyStateText: {
    fontSize: 20,
    marginHorizontal: width / 8,
    color: COLORS.attributes,
  }
});

module.exports = HistoryScreen;