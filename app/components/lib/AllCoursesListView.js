import React, {
  ListView,
  InteractionManager,
  View,
  Text,
  StyleSheet,
} from 'react-native';

import InfiniteScrollView from 'react-native-infinite-scroll-view';
import SearchBar from 'react-native-search-bar';
import Loader from './Loader';
import { SHEET } from '../../CommonStyles'
const logger = new (require('../../../modules/Logger'))('AllCoursesListView');

class AllCoursesListView extends React.Component {

  constructor(props = {}) {
    super(props);
    this.courses = {};

    this.state = {
      dataSource: new ListView.DataSource({
        rowHasChanged: (row1, row2) => row1 !== row2,
      }),
      loaded: false,
      canLoadMore: true,
    }
  }

  componentWillMount() {
    this.loadMore()
  }

  loadMore() {
    InteractionManager.runAfterInteractions(() => {
      this.setState({
        isLoadingMore: true
      })

      return this.props.ddp.call({
        methodName: 'courses/get',
        params: [this.state.searchText, this.state.offset]})
      .then(result => {
        result.courses.forEach(course => {
          this.courses[course._id] = course
        })

        let courseValues = Object.keys(this.courses).map(key => this.courses[key])

        if (this.state.searchText) {
          const regex = new RegExp(`^${this.state.searchText}`, 'i');
          courseValues = courseValues.filter(course => {
            logger.info(`course=${JSON.stringify(course)}`)
            return regex.exec(course.courseCode) != null
          })
        }

        this.setState({
          dataSource: this.state.dataSource.cloneWithRows(courseValues),
          offset: result.offset,
          canLoadMore: result.canLoadMore,
          isLoadingMore: false
        })
      })
      .catch(err => {
        logger.error(err);
      })
    });
  }

  search(text) {
    text = text.trim().toLowerCase();

    this.setState({
      searchText: text,
      offset: 0,
    });
    this.loadMore()
  }

  render() {
    return (
      <View style={this.props.style}>
        <SearchBar
          ref='searchBar'
          text={this.state.searchText}
          style={styles.searchBar}
          placeholder={'Search'}
          hideBackground={true}
          onChangeText={(text) => this.search.bind(this)(text)} />

        <ListView
          style={SHEET.innerContainer}
          distanceToLoadMore = {0}
          initialListSize={1}
          renderScrollComponent={props => <InfiniteScrollView {...props} />}
          dataSource={this.state.dataSource}
          renderRow={this.props.renderCourse}
          canLoadMore={this.state.canLoadMore}
          isLoadingMore={this.state.isLoadingMore}
          onLoadMoreAsync={this.loadMore.bind(this)} />
      </View>
    )
  }
}

var styles = StyleSheet.create({
  searchBar: {
    height: 50,
  },
});

export default AllCoursesListView;
