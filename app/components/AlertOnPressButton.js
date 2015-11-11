let React = require('react-native');

let {
  AppRegistry,
  TouchableHighlight,
  AlertIOS,
} = React;

class AlertOnPressButton extends React.Component {
  render() {
    return (
      <TouchableHighlight onPress={() => {
        AlertIOS.alert(
          this.props.title,
          this.props.content,
          [
            {text: 'Cancel', onPress: () => console.log('cancelled')},
            {text: 'Okay', onPress: () => console.log('okayed')},
          ]
        )
      }}>
        { this.props.children }
      </TouchableHighlight>
    )
  }
}

module.exports = AlertOnPressButton;
