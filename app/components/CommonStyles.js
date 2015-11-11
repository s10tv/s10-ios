let React = require('react-native');

let {
  StyleSheet
} = React;

let BACKGROUND_COLOR = '#e0e0e0';
let TAYLR_COLOR = '#64369C';

exports.COLORS = {
  background: BACKGROUND_COLOR,
  taylr: TAYLR_COLOR,
};

exports.SHEET = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: BACKGROUND_COLOR,
  },

  innerContainer: {
    marginHorizontal: 15,
  },

  navTop: {
    paddingTop: 64,
  },

  bottomTile: {
    paddingBottom: 64,
  },

  separator: {
    backgroundColor: BACKGROUND_COLOR,
    height: 1
  },
});