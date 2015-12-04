import React, {
  Image,
  View,
  StyleSheet,
} from 'react-native'

import { connect } from 'react-redux/native';
import TabNavigator from 'react-native-tab-navigator';

import MeScreen from './me/MeScreen';
import DiscoverScreen from './discover/DiscoverScreen';
import ConversationListView from './chat/ConversationListView';

import { SWITCH_BASE_TAB } from '../constants'

function mapStateToProps(state) {
  return {
    routes: {
      root: {
        currentTab: state.routes.root.currentTab
      }
    }
  }
}

class TabNavigatorScreen extends React.Component {

  render() {
    return (
      <TabNavigator>
        <TabNavigator.Item
          renderIcon={() => <Image source={require('./img/ic-me.png')}/>}
          renderSelectedIcon={() => <Image style={styles.selected} source={require('./img/ic-me.png')}/>}
          selectedTitleStyle={styles.selectedText}
          onPress={() => {
            this.props.dispatch({
              type: SWITCH_BASE_TAB,
              currentTab: 'Me'
            })
            this.props.dispatch({ type: MeScreen.id })
          }}
          selected={this.props.routes.root.currentTab == 'Me'}>

          <MeScreen {...this.props} />

        </TabNavigator.Item>
        <TabNavigator.Item
          renderIcon={() => <Image source={require('./img/ic-compass.png')}/>}
          renderSelectedIcon={() => <Image style={styles.selected} source={require('./img/ic-compass.png')}/>}
          selectedTitleStyle={styles.selectedText}
          onPress={() => {
            this.props.dispatch({
              type: SWITCH_BASE_TAB,
              currentTab: 'Today'
            })
            this.props.dispatch({ type: DiscoverScreen.id })
          }}
          selected={this.props.routes.root.currentTab == 'Today'}>

          <DiscoverScreen {...this.props} />

        </TabNavigator.Item>
        <TabNavigator.Item
          badgeText={0} // TODO(qimingfang):
          renderIcon={() => <Image source={require('./img/ic-chats.png')}/>}
          renderSelectedIcon={() => <Image style={styles.selected} source={require('./img/ic-chats.png')}/>}
          selectedTitleStyle={styles.selectedText}
          onPress={() => {
            this.props.dispatch({
              type: SWITCH_BASE_TAB,
              currentTab: 'Conversations'
            })
            this.props.dispatch({ type: ConversationListView.id })
          }}
          selected={this.props.routes.root.currentTab == 'Conversations'}>

          <ConversationListView {...this.props} />
        </TabNavigator.Item>
      </TabNavigator>
    )
  }
}

let styles = StyleSheet.create({
  selected: {
    tintColor: '#64369C',
  },
  selectedText: {
    color: '#64369C',
  }
});

export default connect(mapStateToProps)(TabNavigatorScreen)
