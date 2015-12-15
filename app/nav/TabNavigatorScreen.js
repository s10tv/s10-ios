import React, {
  Image,
  View,
  PropTypes,
  StyleSheet,
} from 'react-native'

import { connect } from 'react-redux/native';
import TabNavigator from 'react-native-tab-navigator';

import Routes from './Routes';
import DiscoverScreen from '../components/discover/DiscoverScreen';
import ConversationListView from '../components/chat/ConversationListView';

import { SWITCH_BASE_TAB, TAB_SCREEN_CONTAINER } from '../constants'

const logger = new (require('../../modules/Logger'))('TabNavigatorScreen');

function mapStateToProps(state) {
  return {
    me: state.me,
    currentScreen: state.currentScreen,
  }
}

class TabNavigatorScreen extends React.Component {

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
              id: 'SCREEN_ME'
            })
          }}
          selected={this.props.currentScreen.id == 'SCREEN_ME'}>

          { Routes.instance.getProfileRoute({
            user: this.props.me,
            isEditable: true,
            isFromMeScreen: true,
            additionalProps: this.props }).renderScene(this.props.navigator)}

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
          selected={this.props.currentScreen.id == DiscoverScreen.id}>

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
          selected={this.props.currentScreen.id == ConversationListView.id}>

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
