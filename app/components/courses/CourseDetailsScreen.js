import React, {
  Dimensions,
  Image,
  Text,
  View,
  ListView,
  InteractionManager,
  TouchableOpacity,
  PropTypes,
  StyleSheet,
} from 'react-native';

import { connect } from 'react-redux/native';
import { TappableCard } from '../lib/Card';
import iconTextRow from '../lib/iconTextRow';
import { SHEET, COLORS } from '../../CommonStyles';
import SimilarityCalculator from '../../util/SimilarityCalculator';
import { activeCourseCard } from './coursesCommon';
import Loader from '../lib/Loader';
import Routes from '../../nav/Routes';

const { height, width } = Dimensions.get('window')
const logger = new (require('../../../modules/Logger'))('CourseDetailsScreen');

function mapStateToProps(state) {
  return {
    me: state.me,
    myTags: state.myTags,
    myCourses: state.myCourses,
    ddp: state.ddp,
  }
}

class CourseDetailsScreen extends React.Component {

  constructor(props) {
    super(props);
    this.similarityCalculator = new SimilarityCalculator();
    this.state = {
      dataSource: new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2}),
    };
  }

  componentWillMount() {
    InteractionManager.runAfterInteractions(() => {
      this.props.ddp.subscribe({
        pubName: 'course-details',
        params: [this.props.courseCode],
        userRequired: false })
      .then((subId) => {
        this.subId = subId;

        this.observer = this.props.ddp.collections.observe(() => {
          return this.props.ddp.collections.coursedetails.find({ courseCode: this.props.courseCode});
        }).subscribe(courses => {
          if (courses.length > 0) {
            const [course] = courses;

            this.setState({
              course: course
            })

            if (course.usersInCourse) {
              const usersInCourse = course.usersInCourse.filter(user => {
                return user._id != this.props.me._id
              }).map(user => {
                return this.props.ddp._formatUser(user);
              })

              this.setState({
                dataSource: this.state.dataSource.cloneWithRows(usersInCourse)
              })
            }
          }
        });
      })
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

  renderHeader() {
    return activeCourseCard(this.state.course, false, null, null, { borderRadius: 0, marginVertical: 0});
  }

  _renderSimilarities(user) {
    const similarities = this.similarityCalculator.calculate(this.props.me, user);

    const courseSimilarities = similarities.same.courses.map(course => {
      return `${course.dept} ${course.course}`;
    })
    const tagSimilarities = similarities.same.tags.map(tag => {
      return tag.text;
    });
    const allSimilarities = courseSimilarities.concat(tagSimilarities);

    if (allSimilarities.length > 0) {
      const sampleSimilarities = allSimilarities.slice(0,1);
      if (allSimilarities.length > 1) {
        sampleSimilarities.push(`${allSimilarities.length - 1} more`);
      }

      return (
        <View style={styles.similarityContainer}>
          <View style={SHEET.separator} />
          <View style={styles.similarities}>
            <Text style={styles.inCommon}>Common:</Text>
            { sampleSimilarities.map(similarity => {
              return (
                <View key={similarity} style={styles.similarity}>
                  <Text style={[{ color: COLORS.taylr}]}>{ similarity }</Text>
                </View>
              )
            })}
          </View>
        </View>
      )
    }

    return null;
  }

  renderUserInCourse(user) {
    return (
      <TappableCard key={user._id} style={[styles.card, SHEET.innerContainer]}
          onPress={() => {
            const route = Routes.instance.getProfileRoute({
              user: user, isFromCoursesView: true });
            this.props.navigator.parentNavigator.push(route);
          }}
          cardOverride={{padding: 10, borderRadius: 3}}
          hideSeparator={true}>
        <View>
          <View style={{ flexDirection: 'row' }}>
            <Image source={{ uri: user.avatarUrl }} style={styles.avatar} />
            <View style={styles.userInfo}>
              <Text>{user.displayName}</Text>
              {iconTextRow(require('../img/ic-mortar.png'), user.major, styles.userIconTextRow)}
              {iconTextRow(require('../img/ic-house.png'), user.hometown, styles.userIconTextRow)}
            </View>
          </View>
          { this._renderSimilarities(user) }
        </View>
      </TappableCard>
    )
  }

  render() {
    if (!this.state.course) {
      return <Loader />
    }

    return (
      <View style={SHEET.container}>
        <ListView
          dataSource={this.state.dataSource}
          renderHeader={() => { return this.renderHeader()}}
          renderRow={(userInCourse) => { return this.renderUserInCourse(userInCourse) }}
        />
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
    marginLeft: 5,
  },
  userIconTextRow: {
    padding: 0,
    marginTop: 5,
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
    height: 35,
    alignItems: 'center',
  },
  similarity: {
    borderWidth: 1,
    borderColor: COLORS.taylr,
    paddingHorizontal: 5,
    paddingVertical: 2,
    marginRight: 5,
  },
})


export default connect(mapStateToProps)(CourseDetailsScreen)
