import React, {
  Image,
  View,
  StyleSheet,
} from 'react-native'

import { connect } from 'react-redux/native';
import TabNavigator from 'react-native-tab-navigator';

import TabRouter from './TabRouter';
import MeScreen from '../components/me/MeScreen';
import DiscoverScreen from '../components/discover/DiscoverScreen';
import ConversationListView from '../components/chat/ConversationListView';

import { SWITCH_BASE_TAB, TAB_SCREEN_CONTAINER } from '../constants'

const logger = new (require('../../modules/Logger'))('TabNavigatorScreen');

function mapStateToProps(state) {
  return {
    currentScreen: state.currentScreen,
  }
}

class TabNavigatorScreen extends React.Component {

  static id = TAB_SCREEN_CONTAINER;
  static router = new TabRouter();

  static leftButton(route, router) {
    return TabNavigatorScreen.router.leftButton(route, router)
  }

  static rightButton(route, router) {
    return TabNavigatorScreen.router.rightButton(route, router)
  }

  static title(route, router) {
    return TabNavigatorScreen.router.title(route, router)
  }

  render() {
    return (
      <TabNavigator>
        <TabNavigator.Item
          renderIcon={() => <Image source={require('../components/img/ic-me.png')}/>}
          renderSelectedIcon={() => <Image style={styles.selected} source={require('../components/img/ic-me.png')}/>}
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
          renderIcon={() => <Image source={require('../components/img/ic-compass.png')}/>}
          renderSelectedIcon={() => <Image style={styles.selected} source={require('../components/img/ic-compass.png')}/>}
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
          renderIcon={() => <Image source={require('../components/img/ic-chats.png')}/>}
          renderSelectedIcon={() => <Image style={styles.selected} source={require('../components/img/ic-chats.png')}/>}
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
