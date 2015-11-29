'use strict';

var React = require('react-native');
var { StyleSheet, Text, View, TextInput, Animated, TouchableOpacity } = React;

let SHEET = require('../CommonStyles').SHEET;

var FloatingLabel = React.createClass({
  getInitialState: function() {
    return {
      paddingAnim: new Animated.Value(9),
      opacityAnim: this.props.visible ? new Animated.Value(1) : new Animated.Value(0)
    };
  },

  componentWillReceiveProps: function(newProps) {
    Animated.timing(this.state.paddingAnim, {
      toValue: newProps.visible ? 5 : 9,
      duration: 230
    }).start();

    return Animated.timing(this.state.opacityAnim, {
      toValue: newProps.visible ? 1 : 0,
      duration: 230
    }).start();
  },

  render: function() {
    return(
      <Animated.View style={[styles.floatingLabel, {paddingTop: this.state.paddingAnim, opacity: this.state.opacityAnim}]}>
        {this.props.children}
      </Animated.View>
    );
  }
});

var TextFieldHolder = React.createClass({
  getInitialState: function() {
    return {
      marginAnim: new Animated.Value(this.props.withValue ? 10 : 0)
    };
  },

  componentWillReceiveProps: function(newProps) {
    return Animated.timing(this.state.marginAnim, {
      toValue: newProps.withValue ? 10 : 0,
      duration: 230
    }).start();
  },

  render: function() {
    return(
      <Animated.View style={{marginTop: this.state.marginAnim}}>
        {this.props.children}
      </Animated.View>
    );
  }
});

class FloatLabelTextField extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      focussed: false,
      text: this.props.value,
      height: 20,
    };
  }

  onHiddenLayout(event) {
    if (event.nativeEvent.layout.height != this.state.height) {
      this.setState({ height: event.nativeEvent.layout.height })
    }
  }

  render() {
    let textInputExtra = this.props.multiline ? { height: this.state.height + 10 } : null;
    let containerExtra = this.props.multiline? { height: this.state.height + 35 } : null;

    let changeableElement = this.props.tapElement ? this.props.tapElement : (
      <TextInput
        placeholder={this.props.placeHolder}
        style={[styles.valueText, textInputExtra]}
        value={this.state.text}
        editable={this.props.ddp.connected && this.props.ddp.loggedIn}
        multiline={this.props.multiline}
        onFocus={this.setFocus.bind(this)}
        onBlur={this.unsetFocus.bind(this)}
        onChangeText={this.setText.bind(this)}
        secureTextEntry={this.props.secureTextEntry} />
    )

    return(
      <View style={[styles.container, containerExtra]}>
        <Text
         ref="hidden"
         onLayout={this.onHiddenLayout.bind(this)}
         style={[styles.hidden, SHEET.baseText]}>
          {this.state.text}
        </Text>
        <View style={styles.viewContainer}>
          <View style={styles.paddingView}></View>
          <View style={styles.fieldContainer}>
            <FloatingLabel visible={this.state.text || this.props.value}>
              <Text style={[styles.fieldLabel, this.labelStyle(), SHEET.baseText]}>
                {this.placeHolderValue()}
              </Text>
            </FloatingLabel>
            <TextFieldHolder withValue={this.state.text}>
              { changeableElement } 
            </TextFieldHolder>
          </View>
        </View>
      </View>
    );
  }

  setFocus() {
    this.setState({
      focussed: true
    });
    try {
      return this.props.onFocus();
    } catch (_error) {}
  }

  unsetFocus() {
    this.setState({
      focussed: false
    });
    try {
      return this.props.onBlur(this.state.text);
    } catch (_error) {}
  }

  labelStyle() {
    if (this.state.focussed) {
      return styles.focussed;
    }
  }

  placeHolderValue() {
    if (this.state.text || this.props.value) {
      return this.props.placeHolder;
    }
  }

  setText(value) {
    this.setState({
      text: value
    });
    try {
      return this.props.onChangeText(value);
    } catch (_error) {}
  }

  withMargin() {
    if (this.state.text) {
      return styles.withMargin;
    }
  }
}

var styles = StyleSheet.create({
  container: {
    flex: 1,
    height: 55,
    backgroundColor: 'white',
    justifyContent: 'center'
  },
  hidden: {
    position: 'absolute',
    fontSize: 18,
    paddingLeft: 20,
    paddingRight: 5,
    backgroundColor: 'transparent',
    top: 10000,
    left: 10000,
  },
  viewContainer: {
    flex: 1,
    flexDirection: 'row'
  },
  paddingView: {
    width: 15
  },
  floatingLabel: {
    position: 'absolute',
    top: 0,
    left: 0
  },
  fieldLabel: {
    height: 14,
    fontSize: 12,
    color: '#B1B1B1'
  },
  fieldContainer: {
    flex: 1,
    justifyContent: 'center',
    position: 'relative'
  },
  valueText: {
    height: 20,
    fontSize: 16,
    color: '#111111'
  },
  withMargin: {
    marginTop: 10
  },
  focussed: {
    color: "#1482fe"
  }
});

module.exports = FloatLabelTextField;