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
    return (
      <View style={[styles.cover, { height: this.props.height }]}>
        <Image style={styles.cover} source={{ uri: this.props.url }}>
          { this.renderShadow() }
        </Image>

        { this.props.children }
      </View>
    )
  }
}

var styles = StyleSheet.create({
  cover: {
    flex: 1,
  },
  coverShadow: {
    flex: 1,
    backgroundColor: 'black',
    opacity: 0.5,
  }
});

module.exports = HeaderBanner;
