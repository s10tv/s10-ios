let React = require('react-native');

let {
  AppRegistry,
  ActivityIndicatorIOS,
  View,
  StyleSheet,
} = React;

let Overlay = require('react-native-overlay');
let Dimensions = require('Dimensions');
let { height } = Dimensions.get('window');

class OverlayLoader extends React.Component {
  render() {
    return (
      <Overlay isVisible={true}>
        <View style={styles.container}>
          <ActivityIndicatorIOS
            animating={true}
            style={styles.centering}
            size="small" />
        </View>
      </Overlay>
    )
  }
}

var styles = StyleSheet.create({
  container: {
    flex: 1,
    opacity: 0.5,
    backgroundColor: '#FFFFFF',
    justifyContent: 'center',
    alignItems: 'center'
  },
  centering: {
    alignItems: 'center',
    justifyContent: 'center',
    height: height,
  }
})

module.exports = OverlayLoader;