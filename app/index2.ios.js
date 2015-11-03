/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 */
'use strict';

var React = require('react-native');
var ContainerView = require('./components/ContainerView');
var {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  NativeModules,
  MapView,
  NavigatorIOS,
  TabBarIOS,
} = React;

var mainViewManager = NativeModules.MainViewManager;
mainViewManager.testMethod('Some stuff', 'Some other stuff');

class MyView extends React.Component {
  render() {
    return (
        <Text>
          This is a far better development flow than most of Native iOS
          Far less compilation, no need to lift my finger off the keyboard
          Things are not invalid. Life is better this way yo
        </Text>
        )
  }
}

var base64Icon = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEsAAABLCAQAAACSR7JhAAADtUlEQVR4Ac3YA2Bj6QLH0XPT1Fzbtm29tW3btm3bfLZtv7e2ObZnms7d8Uw098tuetPzrxv8wiISrtVudrG2JXQZ4VOv+qUfmqCGGl1mqLhoA52oZlb0mrjsnhKpgeUNEs91Z0pd1kvihA3ULGVHiQO2narKSHKkEMulm9VgUyE60s1aWoMQUbpZOWE+kaqs4eLEjdIlZTcFZB0ndc1+lhB1lZrIuk5P2aib1NBpZaL+JaOGIt0ls47SKzLC7CqrlGF6RZ09HGoNy1lYl2aRSWL5GuzqWU1KafRdoRp0iOQEiDzgZPnG6DbldcomadViflnl/cL93tOoVbsOLVM2jylvdWjXolWX1hmfZbGR/wjypDjFLSZIRov09BgYmtUqPQPlQrPapecLgTIy0jMgPKtTeob2zWtrGH3xvjUkPCtNg/tm1rjwrMa+mdUkPd3hWbH0jArPGiU9ufCsNNWFZ40wpwn+62/66R2RUtoso1OB34tnLOcy7YB1fUdc9e0q3yru8PGM773vXsuZ5YIZX+5xmHwHGVvlrGPN6ZSiP1smOsMMde40wKv2VmwPPVXNut4sVpUreZiLBHi0qln/VQeI/LTMYXpsJtFiclUN+5HVZazim+Ky+7sAvxWnvjXrJFneVtLWLyPJu9K3cXLWeOlbMTlrIelbMDlrLenrjEQOtIF+fuI9xRp9ZBFp6+b6WT8RrxEpdK64BuvHgDk+vUy+b5hYk6zfyfs051gRoNO1usU12WWRWL73/MMEy9pMi9qIrR4ZpV16Rrvduxazmy1FSvuFXRkqTnE7m2kdb5U8xGjLw/spRr1uTov4uOgQE+0N/DvFrG/Jt7i/FzwxbA9kDanhf2w+t4V97G8lrT7wc08aA2QNUkuTfW/KimT01wdlfK4yEw030VfT0RtZbzjeMprNq8m8tnSTASrTLti64oBNdpmMQm0eEwvfPwRbUBywG5TzjPCsdwk3IeAXjQblLCoXnDVeoAz6SfJNk5TTzytCNZk/POtTSV40NwOFWzw86wNJRpubpXsn60NJFlHeqlYRbslqZm2jnEZ3qcSKgm0kTli3zZVS7y/iivZTweYXJ26Y+RTbV1zh3hYkgyFGSTKPfRVbRqWWVReaxYeSLarYv1Qqsmh1s95S7G+eEWK0f3jYKTbV6bOwepjfhtafsvUsqrQvrGC8YhmnO9cSCk3yuY984F1vesdHYhWJ5FvASlacshUsajFt2mUM9pqzvKGcyNJW0arTKN1GGGzQlH0tXwLDgQTurS8eIQAAAABJRU5ErkJggg==';

var Taylr = React.createClass({
  getInitialState: function() {
    return {
      selectedTab: 'discover',
    }
  },

  render: function() {
    return (<ContainerView sbName='Me' />)
    // return (
    //   <NavigatorIOS
    //     style={styles.navigator}
    //     itemWrapperStyle={styles.itemWrapper}
    //     tintColor='white'
    //     // barTintColor='black'
    //     initialRoute={{
    //       component: ContainerView,
    //       title: 'Sup people',
    //       passProps: {
    //         sbName: 'Me',
    //         // style: styles.container,
    //       }
    //     }}
    //   /> 
    // )

    return (
      <TabBarIOS 
        tintColor="white"
        barTintColor="darkslateblue"
        style={styles.container}>
        <TabBarIOS.Item
          selected={this.state.selectedTab === 'me'}
          onPress={() => {
            this.setState({
              selectedTab: 'me',
            });
          }}
          icon={{uri: base64Icon, scale: 3}}
          title="Me">
          <ContainerView sbName='Me' />
        </TabBarIOS.Item>
        <TabBarIOS.Item
          selected={this.state.selectedTab === 'discover'}
          onPress={() => {
            this.setState({
              selectedTab: 'discover',
            });
          }}
          icon={{uri: base64Icon, scale: 3}}
          title="Discover">
          <ContainerView sbName='Discover' />
        </TabBarIOS.Item>
        <TabBarIOS.Item
          selected={this.state.selectedTab === 'conversation'}
          onPress={() => {
            this.setState({
              selectedTab: 'conversation',
            });
          }}
          icon={{uri: base64Icon, scale: 3}}
          title="Conversation">
          <ContainerView sbName='Conversation' />
        </TabBarIOS.Item>
      </TabBarIOS>
    )
    

    // return (
    //   <View style={styles.container}>
    //     <Text style={styles.welcome}>
    //       This is a far better development flow than most of Code
    //     </Text>
    //     <Text style={styles.instructions}>
    //     Once someone worked out the rough edges, that's where I come in
    //     Pretty sweat
    //     </Text>
    //     <Text style={styles.instructions}>
    //       Press Cmd+R to reload,{'\n'}
    //       Cmd+D or shake for dev menu
    //     </Text>
    //   </View>
    // );
  }
});

var styles = StyleSheet.create({
  navigator: {
    flex: 1
  },
  itemWrapper: {
    backgroundColor: 'purple',
    // justifyContent: 'center',
    // alignItems: 'center',
  },
  container: {
    // width: 375,
    // height: 667,
    // flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
    // height: 100,
    // width: 100,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});

AppRegistry.registerComponent('SimpleApp', () => Taylr);
