let React = require('react-native');
let Button = require('react-native-button');
let _ = require('lodash');

let {
  AppRegistry,
  View,
  ScrollView,
  Text,
  Image,
  TouchableOpacity,
  StyleSheet,
} = React;

let Dimensions = require('Dimensions');
let { width, height } = Dimensions.get('window');

let SHEET = require('../CommonStyles').SHEET;
let COLORS = require('../CommonStyles').COLORS;

let Loader = require('../lib/Loader');
let TappableCard = require('../lib/Card').TappableCard;

class HistoryProfile extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      height: props.height
    };
  }

  render() {
    let candidate = this.props.candidate;
    let user = this.props.user;
    let height = this.state. height;

    return (
      <TappableCard
        key={candidate._id}
        style={[styles.imgContainer, {height: height} ]}
        cardOverride={{ padding: 0 }}
        onPress={() => { this.props.parentNavigator.push({
          id: 'viewprofile',
          me: user
        }) }}>
          <View style={[styles.imgContainer, {height: height} ]}>
            <Image style={{ flex: 1, resizeMode: 'cover' }} source={{ uri: user.avatar.url }}>
              <View style={{ width: width / 2 - 10, height: 35, backgroundColor: 'black',
                  opacity: 0.60, position:'absolute', bottom: 0}}>
                <View style={{flex: 1, flexDirection: 'row', margin: 10}}>
                  <Text style={[SHEET.baseText, { flex: 1, color: 'white', }]}>
                    {user.firstName} {user.gradYear}
                  </Text>
                </View>
              </View>
            </Image>
            <Text style={{ padding: 10 }}>{candidate.reason}</Text>
          </View>
      </TappableCard>
    );
  }
}

class HistoryScreen extends React.Component {

  // TODO: COPY/PASTE alert. From Activities
  _timeDifference(current, previous) {
    var msPerMinute = 60 * 1000;
    var msPerHour = msPerMinute * 60;
    var msPerDay = msPerHour * 24;
    var msPerWeek = msPerDay * 7;

    var elapsed = current - previous;
    let difference = Math.round(elapsed/msPerDay);
    if (difference === 0) {
      return 'Today';
    } else if (difference === 1) {
      return 'Yesterday';
    } else {
      return `${difference} days ago`;
    }
  }

  createProfiles(candidates) {
    var heights = [325, 300, 250, 200, 175];

    return candidates.map((candidate) => {
      let user = this.props.ddp.collections.users.findOne({ _id: candidate.userId });
      let cardHeight = candidate.height ? candidate.height : _.sample(heights)

      return (
        <View stlye={{ flex: 1}}>
          <Text style={[{ paddingTop: 12, paddingBottom: 3 }, SHEET.baseText]}>
              {this._timeDifference(new Date(), candidate.date)}
          </Text>
          <HistoryProfile
            parentNavigator={this.props.parentNavigator}
            candidate={candidate}
            user={user}
            height={cardHeight} />
        </View>
      );
    });
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

      let firstList = history.filter((elem, idx) => {
        return idx % 2 == 0 
      })

      const [ first ] = firstList;
      if (first) {
        first.height = 300;
      }

      let secondList = history.filter((elem, idx) => {
        return idx % 2 == 1
      })

      const [ second ] = secondList;
      if (second) {
        second.height = 225;
      }


      historyView = (
        <ScrollView showsVerticalScrollIndicator={false} style={styles.scroll}>
          <View style={styles.wrapper}>
              <View style={styles.row}>
                {this.createProfiles(firstList)}
              </View>

              <View style={[styles.row, {marginRight: 0}]}>
                {this.createProfiles(secondList)}
              </View>
          </View>
        </ScrollView>
      )
    }

    return (
      <View style={SHEET.container}>
        <View style={{flex: 1, paddingTop: 64,}}>
          { historyView } 
        </View>
      </View>
    )
  }
}

var styles = StyleSheet.create({
  wrapper: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginRight: 8,
    marginLeft: 8, 
  },
  scroll: {
    flex: 1,
  },
  row: {
    flex: 1,
    flexDirection: 'column',
    flexWrap: 'wrap',
    marginRight: 10
  },
  imgContainer: {
    height: 200,
    marginBottom: 6
  },
  images: {
    flex: 1,
    resizeMode: 'cover'
  },
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