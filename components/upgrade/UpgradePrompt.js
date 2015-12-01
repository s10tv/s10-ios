let React = require('react-native');

let {
  TouchableOpacity,
  Text,
  Image,
  LinkingIOS,
  AlertIOS,
  View,
  StyleSheet,
} = React;

let Dimensions = require('Dimensions');
let { width, height } = Dimensions.get('window');
var Overlay = require('react-native-overlay');

const logger = new (require('../../modules/Logger'))('UpgradePrompt');

class UpgradePrompt extends React.Component {

  constructor(props = {}) {
    super(props);
  }

  render() {
    let buttons = null;
    let title = null;
    let content = null;

    if (this.props.hardUpgradeURL) {
      title = 'Upgrade needed';
      content = 'Your version of Taylr is no longer supported. Please upgrade.';
      buttons = (
        <View style={styles.actions}>
          <TouchableOpacity style={styles.button} onPress={() => {
            LinkingIOS.canOpenURL(this.props.hardUpgradeURL, (supported) => {
              if (!supported) {
                logger.warning(`${this.props.hardUpgradeURL} unsupported.`)
                return;
              } else {
                LinkingIOS.openURL(this.props.hardUpgradeURL);
              }
            });
          }}>
            <Text style={[styles.buttonText, styles.installButton]}>
              Upgrade
            </Text>
          </TouchableOpacity>
        </View>
      );
    } else {
      title = 'New version available';
      content = "It's awesome and we think you should give it a try.";
      buttons = (
        <View style={styles.actions}>
          <TouchableOpacity style={[styles.button, styles.cancelButton]} onPress={() => {
            this.props.hideModal();
          }}>
            <Text style={[styles.buttonText, styles.cancelButton]}>
              Cancel
            </Text>
          </TouchableOpacity>

          <View style={styles.divider} />

          <TouchableOpacity style={styles.button} onPress={() => {
            if (this.props.upgrade) {
              this.props.upgrade();
            } else {
              logger.warning('Trying to upgrade but cannot find upgrade function');
            }

            this.props.hideModal();
          }}>
            <Text style={[styles.buttonText, styles.installButton]}>
              Install
            </Text>
          </TouchableOpacity>
        </View>
      );
    }

    return (
      <Overlay isVisible={this.props.modalVisible}>
        <View style={styles.background}>
          <View style={styles.backdrop} />
          <View style={styles.picker}>

            <Text style={styles.title}>{ title }</Text>
            <Text style={styles.content}>{ content }</Text>

            { buttons }
          </View>
        </View>
      </Overlay>
    )
  }
}

var styles = StyleSheet.create({
  cards: {
    marginVertical: 5,
  },
  backdrop: {
    position: 'absolute',
    top: 0,
    left: 0,
    width: width,
    height: height,
    backgroundColor: 'black',
    opacity: 0.75,
  },
  title: {
    fontSize: 22,
    padding: 6,
    textAlign: 'center',
  },
  content: {
    fontSize: 16,
    padding: 16,
    textAlign: 'center',
  },
  background: {
    position: 'absolute',
    width: width,
    height: height,
    justifyContent: 'center',
  },
  picker: {
    backgroundColor: 'white',
    marginHorizontal: width / 8,
    borderColor: 'white',
    borderWidth: 1,
    paddingTop: 6,
    borderRadius: 6,
  },
  actions: {
    flex: 1,
    flexDirection: 'row',
    borderTopColor: '#cccccc',
    borderTopWidth: 1,
  },
  buttonText: {
    color: '#0069d5',
    alignSelf: 'center',
    fontSize: 18
  },
  cancelButton: {
  },
  installButton: {
    fontWeight: 'bold',
  },
  divider: {
    width: 1,
    height: 46,
    backgroundColor: '#cccccc',
  },
  button: {
    flex: 1,
    height: 46,
    backgroundColor: 'white',
    alignSelf: 'stretch',
    justifyContent: 'center'
  }
});

export default UpgradePrompt;
