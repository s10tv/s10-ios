import React, {
  Dimensions,
  Text,
  WebView,
  Image,
  StyleSheet,
  View,
  ScrollView,
} from 'react-native';

import _ from 'lodash';
import { connect } from 'react-redux/native';
import { SCREEN_HISTORY } from '../../constants';

import Screen from '../Screen';
import { TappableCard } from '../lib/Card';
import Loader from '../lib/Loader';
import { SHEET, COLORS } from '../../CommonStyles';

const { width, height } = Dimensions.get('window');

function mapStateToProps(state) {
  return {
    history: state.pastCandidates,
    ddp: state.ddp,
  }
}

class HistoryProfile extends Screen {
  render() {
    let candidate = this.props.candidate;
    let user = this.props.user;
    let height = this.props.height;

    return (
      <TappableCard
        key={candidate._id}
        style={[styles.imgContainer, {height: height} ]}
        cardOverride={{ padding: 0 }}
        onPress={() => { this.props.onViewProfile({ userId: user.userId })}}>
          <View style={[styles.imgContainer, {height: height} ]}>
            <Image style={{ flex: 1, resizeMode: 'cover' }} source={{ uri: user.avatar.url }}>
              <View style={{ width: width / 2 - 10, height: 35, backgroundColor: 'black',
                  opacity: 0.60, position:'absolute', bottom: 0}}>
                <View style={{flex: 1, flexDirection: 'row', margin: 10}}>
                  <Text style={[SHEET.baseText, { flex: 1, color: 'white', }]}>
                    {user.shortDisplayName}
                  </Text>
                </View>
              </View>
            </Image>
            <Text style={[{ padding: 10 }, SHEET.baseText]}>{candidate.reason}</Text>
          </View>
      </TappableCard>
    );
  }
}

class HistoryScreen extends Screen {

  static id = SCREEN_HISTORY;
  static leftButton = (route, router) => Screen.generateButton('Back', router.pop.bind(router));
  static rightButton = () => null
  static title = () => null

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
    var heights = [250];

    return candidates.map((candidate) => {
      let user = this.props.ddp._formatUser(this.props.ddp.collections.users.findOne({ _id: candidate.userId }));
      let cardHeight = candidate.height ? candidate.height : _.sample(heights)

      return (
        <View
          key={candidate._id}
          stlye={{ flex: 1}}>
          <Text style={[{ paddingTop: 12, paddingBottom: 3 }, SHEET.baseText]}>
              {this._timeDifference(new Date(), candidate.date)}
          </Text>
          <HistoryProfile
            candidate={candidate}
            user={user}
            height={cardHeight}
            onViewProfile={this.props.onViewProfile}/>
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
          <Image source={require('../img/band.png')} style={styles.emptyStateImage} />
          <Text style={[styles.emptyStateText, SHEET.baseText]}>
            You will find your previous introductions here.
          </Text>
        </View>
      )
    } else {
      history.sort((one, two) => { return  two.date - one.date })

      let [first, second, ...rest] = history;

      let firstList = [];
      let secondList = [];
      if (rest) {

        // secondList.length >= firstList.length
        firstList = rest.filter((elem, idx) => {
          return idx % 2 == 1
        })

        secondList = rest.filter((elem, idx) => {
          return idx % 2 == 0
        })
      }

      // first is guaranteed to exist
      first.height = 300;
      firstList = [first].concat(firstList)

      if (second) {
        second.height = 200;
        secondList = [second].concat(secondList)
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
    marginHorizontal: width / 8,
  },
  emptyStateImage: {
    width: width / 2,
    height: height / 4,
    resizeMode: 'contain',
  },
  emptyStateText: {
    fontSize: 20,
    color: COLORS.attributes,
    textAlign: 'center',
  }
});

export default connect(mapStateToProps)(HistoryScreen)
