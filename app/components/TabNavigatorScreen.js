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

import { SWITCH_BASE_TAB, TAB_SCREEN_CONTAINER } from '../constants'

function mapStateToProps(state) {
  return {
    currentScreen: state.currentScreen,
  }
}

class TabNavigatorScreen extends React.Component {

  static id = TAB_SCREEN_CONTAINER;

  static leftButton(route) {
    switch(route.id) {
      case MeScreen.id: return MeScreen.leftButton()
      case DiscoverScreen.id: return DiscoverScreen.leftButton()
      case ConversationListView.id: return ConversationListView.leftButton()
    }
    return null
  }

  static rightButton(route) {
    switch(route.id) {
      case MeScreen.id: return MeScreen.rightButton()
      case DiscoverScreen.id: return DiscoverScreen.rightButton()
      case ConversationListView.id: return ConversationListView.rightButton()
    }
    return null
  }

  static title(route) {
    switch(route.id) {
      case MeScreen.id: return MeScreen.title()
      case DiscoverScreen.id: return DiscoverScreen.title()
      case ConversationListView.id: return ConversationListView.title()
    }
    return null
  }

  render() {
    return (
      <TabNavigator>
        <TabNavigator.Item
          renderIcon={() => <Image source={require('./img/ic-me.png')}/>}
          renderSelectedIcon={() => <Image style={styles.selected} source={require('./img/ic-me.png')}/>}
          selectedTitleStyle={styles.selectedText}
          onPress={() => {
            this.props.dispatch({
              type: 'CURRENT_SCREEN',
              id: MeScreen.id,
            })
          }}
          selected={this.props.currentScreen.present.id == MeScreen.id}>

          <MeScreen {...this.props} />

        </TabNavigator.Item>
        <TabNavigator.Item
          renderIcon={() => <Image source={require('./img/ic-compass.png')}/>}
          renderSelectedIcon={() => <Image style={styles.selected} source={require('./img/ic-compass.png')}/>}
          selectedTitleStyle={styles.selectedText}
          onPress={() => {
            this.props.dispatch({
              type: "CURRENT_SCREEN",
              id: DiscoverScreen.id,
            })
          }}
          selected={this.props.currentScreen.present.id == DiscoverScreen.id}>

          <DiscoverScreen {...this.props} />

        </TabNavigator.Item>
        <TabNavigator.Item
          badgeText={0} // TODO(qimingfang):
          renderIcon={() => <Image source={require('./img/ic-chats.png')}/>}
          renderSelectedIcon={() => <Image style={styles.selected} source={require('./img/ic-chats.png')}/>}
          selectedTitleStyle={styles.selectedText}
          onPress={() => {
            this.props.dispatch({
              type: 'CURRENT_SCREEN',
              id: ConversationListView.id,
            })
          }}
          selected={this.props.currentScreen.present.id == ConversationListView.id}>

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
