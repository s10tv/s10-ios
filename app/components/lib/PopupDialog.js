import React, {
  Dimensions,
  TouchableOpacity,
  Text,
  View,
  PropTypes,
  StyleSheet,
} from 'react-native';

import Overlay from 'react-native-overlay';

const { width, height } = Dimensions.get('window');
const logger = new (require('../../../modules/Logger'))('PopupDialog');

class PopupDialog extends React.Component {

  static propTypes = {
    hardUpgrade: PropTypes.func.isRequired,
    hidePopup: PropTypes.func.isRequired,
    isVisible: PropTypes.bool.isRequired,
    buttons: PropTypes.array,
    actionKey: PropTypes.string,
    title: PropTypes.string,
    message: PropTypes.string,
  }

  cancelButton() {
    return {
      text: 'Cancel',
      action: () => { this.props.hidePopup() },
    }
  }

  render() {
    let actions;
    if (this.props.actionKey) {
      // sometimes it's not possible for buttons to come with exact actions, so we allow
      // an action key to be specified to correspond to specific actions.
      switch (this.props.actionKey) {
        case 'APPHUB_INSTALL':
          actions = [
            this.cancelButton(),
            {
              text: 'Install',
              action: () => {
                this.props.upgrade();
                this.props.hidePopup();
              }
            }
          ]
          break;

        case 'HARD_UPGRADE':
          actions = [
            {
              text: 'Install',
              action: () => {
                return this.props.hardUpgrade();
              }
            }
          ]
          break;

      }
    }

    // not set from actionKey (one-off displays are not recommended but suppored nevertheless).
    if (!actions) {
      if (!this.props.buttons || this.props.buttons.length == 0) {
        logger.warning(`rendering popup dialog with no actions`)
        actions = [{
          text: 'Okay',
          action: () => { this.props.hidePopup() },
        }]
      } else {
        actions = this.props.buttons;
      }
    }

    let renderedButtons;
    if (actions.length == 1) {
      const [ button ] = actions;
      renderedButtons = (
        <View style={styles.actions}>
          <TouchableOpacity style={styles.button} onPress={button.action}>
            <Text style={[styles.buttonText, styles.installButton]}>
              {button.text}
            </Text>
          </TouchableOpacity>
        </View>
      );
    } else if (actions.length  >= 2) {
      const [ buttonOne, buttonTwo ] = actions;

      renderedButtons = (
        <View style={styles.actions}>
          <TouchableOpacity
              style={[styles.button, styles.cancelButton]}
              onPress={buttonOne.action}>
            <Text style={[styles.buttonText, styles.cancelButton]}>
              {buttonOne.text}
            </Text>
          </TouchableOpacity>

          <View style={styles.divider} />

          <TouchableOpacity style={styles.button} onPress={buttonTwo.action}>
            <Text style={[styles.buttonText, styles.installButton]}>
              {buttonTwo.text}
            </Text>
          </TouchableOpacity>
        </View>
      );
    }

    return (
      <Overlay isVisible={this.props.isVisible}>
        <View style={styles.background}>
          <View style={styles.backdrop} />
          <View style={styles.picker}>

            <Text style={styles.title}>{ this.props.title }</Text>
            <Text style={styles.content}>{ this.props.message }</Text>

            { renderedButtons }
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

export default PopupDialog;
