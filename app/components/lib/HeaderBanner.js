import React, {
  AppRegistry,
  View,
  Image,
  StyleSheet,
} from 'react-native';

class HeaderBanner extends React.Component {

  renderShadow() {
    if (this.props.hideShadow) {
      return null;
    }
    return (<View style={styles.coverShadow}></View>);
  }

  render() {

    const styleOverride = {};
    if (this.props.roundTopCorners) {
      styleOverride.borderRadius = 5;
      styleOverride.borderColor = 'transparent';
    }

    return (
      <View style={[{ height: this.props.height}, styleOverride]}>
        <Image style={[{height: this.props.height}, styleOverride]} source={{ uri: this.props.url }}>
          { this.renderShadow() }
        </Image>

        { this.props.children }
      </View>
    )
  }
}

var styles = StyleSheet.create({
  coverShadow: {
    flex: 1,
    backgroundColor: 'black',
    opacity: 0.5,
  }
});

module.exports = HeaderBanner;
