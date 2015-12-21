import React, {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  StyleSheet,
  Dimensions,
  Image,
  ListView,
} from 'react-native';

import { connect } from 'react-redux/native';
import { SHEET, COLORS} from '../../CommonStyles';
import { TappableCard } from '../lib/Card';
import sectionTitle from '../lib/sectionTitle';
import Loader from '../lib/Loader';
import Routes from '../../nav/Routes';
import { renderEventCard } from './eventsCommon'
import { renderReasonSection } from '../discover/renderReasonSection';
import iconTextRow from '../lib/iconTextRow';
import { renderCourse, renderTag, renderMoreTag } from '../discover/renderReasonSection';
import SimilarityCalculator from '../../util/SimilarityCalculator';

const logger = new (require('../../../modules/Logger'))('EventCandidateHistoryScreen');
const { width, height } = Dimensions.get('window');

function mapStateToProps(state) {
  return {
    me: state.me,
    ddp: state.ddp,
  }
}

class EventCandidateHistoryScreen extends React.Component {
  constructor(props = {}) {
    super(props);
    this.similarityCalculator = new SimilarityCalculator();
    this.state = {
      dataSource: new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2}),
      isLoading: true,
      isHistoryEmpty: false,
    };
  }

  componentWillMount() {
    this.props.ddp.subscribe({ pubName: 'speedintro-event', params: [this.props.event._id] })
    .then((subId) => {
      this.subId = subId;

      this.observer = this.props.ddp.collections.observe(() => {
        return this.props.ddp.collections.speedintros.find({ type: 'expired' });
      }).subscribe(intros => {
        if (intros.length > 0) {
          const usersForEvent = intros.map(intro => {
            return this.props.ddp._formatUser(intro.user);
          })
          this.setState({ dataSource: this.state.dataSource.cloneWithRows(usersForEvent), isLoading: false });
        } else {
          this.setState({ isLoading: false, isHistoryEmpty: true });
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

  _renderSimilarities(user) {
    const similarities = this.similarityCalculator.calculate(this.props.me, user);

    const courseSimilarities = similarities.same.courses.map(course => {
      return renderCourse(course, { marginVertical: 8 });
    });
    const tagSimilarities = similarities.same.tags.map(tag => {
      return renderTag(tag, { marginVertical: 8 });
    });
    const allSimilarities = courseSimilarities.concat(tagSimilarities);

    if (allSimilarities.length > 0) {
      const sampleSimilarities = allSimilarities.slice(0,1);
      if (allSimilarities.length > 1) {
        sampleSimilarities.push(renderMoreTag(allSimilarities.length - 1, { marginVertical: 8 }));
      }

      return (
        <View style={styles.similarityContainer}>
          <View style={SHEET.separator} />
          <View style={styles.similarities}>
            <Text style={[SHEET.baseText, styles.inCommon]}>In common:</Text>
            { sampleSimilarities }
          </View>
        </View>
      )
    }

    return null;
  }

  renderUserIntroduced(user, rowId) {
    var similarities = this._renderSimilarities(user);

    return (
      <TappableCard key={user._id} style={[styles.card, rowId == 0 && { marginTop: 0 }]}
          onPress={() => {
            const route = Routes.instance.getProfileRoute({
              user: user});
            this.props.navigator.parentNavigator.push(route);
          }}
          cardOverride={[{padding: 10, borderRadius: 3}, similarities && { paddingBottom: 0 }]}
          hideSeparator={true}>
        <View>
          <View style={{ flexDirection: 'row' }}>
            <Image source={{ uri: user.avatarUrl }} style={styles.avatar} />
            <View style={styles.userInfo}>
              <Text style={[SHEET.baseText, styles.displayNameText]}>{user.displayName}</Text>
              {iconTextRow(require('../img/ic-mortar.png'), user.major, styles.userIconTextRow)}
              {iconTextRow(require('../img/ic-house.png'), user.hometown, styles.userIconTextRow)}
            </View>
          </View>
          { similarities }
        </View>
      </TappableCard>
    )
  }

  render() {
    var historyView;

    if (this.state.isLoading) {
      historyView = <Loader />;
    } else if (this.state.isHistoryEmpty) {
      historyView = (
        <View style={styles.emptyStateContainer}>
          <Image source={require('../img/band.png')} style={styles.emptyStateImage} />
          <Text style={[styles.emptyStateText, SHEET.baseText]}>
            You will find your previous introductions here.
          </Text>
        </View>
      )
    } else {
      historyView =
        <ScrollView style={SHEET.innerContainer}>
          {sectionTitle('INTRODUCED TO')}
          <ListView
            dataSource={this.state.dataSource}
            renderRow={(userIntroduced, undefined, rowId) => { return this.renderUserIntroduced(userIntroduced, rowId) }}
          />
        </ScrollView>
    }

    return (
      <View style={SHEET.container}>
        { historyView }
      </View>
    )
  }
}

var styles = StyleSheet.create({
  card: {
    marginTop: 8,
    borderRadius: 3,
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
  avatar: {
    width: width / 5,
    height: width / 5,
    borderRadius: width / 10,
  },
  similarityContainer: {
    paddingTop: 10,
  },
  inCommon: {
    marginRight: 15,
  },
  similarities: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
  },
  similarity: {
    borderWidth: 1,
    borderColor: COLORS.taylr,
    paddingHorizontal: 5,
    paddingVertical: 2,
    marginRight: 5,
  },
  displayNameText: {
    fontSize: 16,
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
})

export default connect(mapStateToProps)(EventCandidateHistoryScreen);
