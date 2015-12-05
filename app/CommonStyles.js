let React = require('react-native');

let {
  StyleSheet
} = React;

let BACKGROUND_COLOR = '#e0e0e0';
let TAYLR_COLOR = '#64369C';
let MESSGE_BUTTON_COLOR = '#62339D';
let EMPTY_HASHTAG = '#cccccc';
let SUBTITLE_COLOR = '#666666';
let ATTRIBUTE_COLOR = '#999999';

exports.COLORS = {
  background: BACKGROUND_COLOR,
  taylr: TAYLR_COLOR,
  button: MESSGE_BUTTON_COLOR,
  emptyHashtag: EMPTY_HASHTAG,
  subtitle: SUBTITLE_COLOR,
  attributes: ATTRIBUTE_COLOR,
  white: 'white'
};

exports.SHEET = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: BACKGROUND_COLOR,
  },
  baseText: {
    fontFamily: 'Cabin-Regular'
  },
  row: {
    flex: 1,
    alignItems: 'center',
    flexDirection: 'row',
  },
  innerContainer: {
    marginHorizontal: 8,
  },
  navTop: {
    marginTop: 64,
  },
  navTopTab: {
    marginTop: 64,
  },
  bottomTile: {
    paddingBottom: 16,
  },
  subTitle: {
    color: SUBTITLE_COLOR,
    fontSize: 14
  },
  smallHeading: {
    paddingVertical: 4,
  },
  smallIcon: {
    width: 24,
    height: 24,
    resizeMode: 'contain',
  },
  smallIconCircle: {
    width: 24,
    height: 24,
    borderRadius: 12,
    resizeMode: 'contain',
  },
  icon: {
    width: 32,
    height: 32,
    resizeMode: 'contain',
  },
  iconCircle: {
    width: 32,
    height: 32,
    borderRadius: 16,
    resizeMode: 'contain',
  },
  bigIconCircle: {
    width: 128,
    height: 128,
    borderRadius: 64,
  },
  separator: {
    backgroundColor: BACKGROUND_COLOR,
    height: 1
  },
  navBarLeftButton: {
    paddingLeft: 10,
  },
  navBarRightButton: {
    paddingRight: 10,
  },
  navBarTitleText: {
    fontSize: 20,
    color:  'white',
    fontWeight: '500',
    marginVertical: 9,
  },
  navBarText: {
    color: 'white',
    fontSize: 16,
    marginVertical: 10,
  },
});
