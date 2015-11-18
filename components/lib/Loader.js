let React = require('react-native');

let {
  AppRegistry,
  ActivityIndicatorIOS,
  View,
  StyleSheet,
} = React;

class Loader extends React.Component {
  render() {
    return (
      <View style={styles.container}>
        <ActivityIndicatorIOS
          animating={true}
          style={styles.centering}
          size="small" />
      </View>
    )
  }
}

var styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
    justifyContent: 'center',
    alignItems: 'center'
  },
  centering: {
    alignItems: 'center',
    justifyContent: 'center',
    height: 80
  }
})

module.exports = Loader;