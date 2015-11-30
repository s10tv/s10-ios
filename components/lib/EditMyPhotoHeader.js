let React = require('react-native');
let AzureClient = require('react-native').NativeModules.TSAzureClient;

let {
  AppRegistry,
  View,
  Text,
  Image,
  TouchableOpacity,
  StyleSheet,
} = React;

let Dimensions = require('Dimensions');
let { width, height } = Dimensions.get('window');
let Button = require('react-native-button');

let Analytics = require('../../modules/Analytics');
let SHEET = require('../CommonStyles').SHEET;
let UIImagePickerManager = require('NativeModules').UIImagePickerManager;

let OverlayLoader = require('./OverlayLoader');

const logger = new (require('../../modules/Logger'))('EditMyPhotoHeader');

class EditMyPhotoHeader extends React.Component {

  constructor(props) {
    super(props);
    this.state = {}
  }

  __selectAndUploadImage(options) {
    let { type, stateKey } = options;

    if (type === 'PROFILE_PIC') {
      Analytics.track('Me: UpdateAvatar');
    } else if (type == 'COVER_PIC') {
      Analytics.track('Me: UpdateCover');
    }

    var options = {
      title: 'Select', // specify null or empty string to remove the title
      cancelButtonTitle: 'Cancel',
      takePhotoButtonTitle: 'Take Photo...', // specify null or empty string to remove this button
      chooseFromLibraryButtonTitle: 'Choose from Library...', // specify null or empty string to remove this button
      quality: 1,
      maxWidth: 640,
      maxHeight: 480,
      allowsEditing: false, // Built in iOS functionality to resize/reposition the image
      noData: false, // Disables the base64 `data` field from being generated (greatly improves performance on large photos)
    };

    UIImagePickerManager.showImagePicker(options, (didCancel, response) => {
      if (didCancel) {
        logger.info('Cancelled image picker');
      } else {
        const source = {uri: response.uri.replace('file://', ''), isStatic: true};

        let taskId =  'task_' + Math.floor(Math.random() * (10000000000 - 10000)) + 10000;
        let newState = {
          taskId: taskId,
          uploading: true,
        };

        newState[stateKey] = source;
        this.setState(newState);

        this.props.ddp.call({ methodName: 'startTask', params:[taskId, type, {
          width: response.width,
          height: response.height,
        }]})
        .then((res) => {
          return AzureClient.putAsync(res.url, source.uri, 'image/jpeg');
        })
        .then(() => {
          return this.props.ddp.call({ methodName: 'finishTask', params: [taskId] });
        })
        .then(() => {
          this.setState({ uploading: false });
        })
        .catch(err => {
          this.setState({ uploading: false })
          logger.error(`Error in file upload: ${JSON.stringify(err)}`);
          alert('There was an error with your file upload. Please try again later.');
        })
      }
    });
  }

  render() {
    let me = this.props.me;

    let shadow = <View style={[{ height: this.props.height }, styles.coverShadow]}></View>;

    var cover = null
    if (this.state.coverSource || (me && me.coverUrl)) {
      let coverUrl =  this.state.coverSource ? this.state.coverSource.uri : me.coverUrl;
      cover = (
        <Image style={[{ height: this.props.height }, styles.cover]} source={{ uri: coverUrl }}>
          { shadow } 
        </Image>
      )
    } else {
      cover = (
        <Image style={[{ height: this.props.height }, styles.cover]} source={require('../img/defaultbg.jpg')}>
          { shadow }
        </Image>
      )
    }

    let avatarUrl = this.state.avatarSource ? this.state.avatarSource.uri :
      me.avatarUrl;

    let loader = this.state.uploading ? <OverlayLoader /> : null;

    return ( 
      <TouchableOpacity onPress={() => {
        if (!this.props.ddp.connected) {
          return;
        }

        return this.__selectAndUploadImage.bind(this)({
          type: 'COVER_PIC', stateKey: 'coverSource'
        })
      }}>
        { loader }
        { cover }
        <Button onPress={() => {
          if (!this.props.ddp.connected) { 
            return
          } 

          return this.__selectAndUploadImage.bind(this)({
            type: 'PROFILE_PIC', 
            stateKey: 'avatarSource'})
        }}>
          <View style={styles.avatarContainer}>
            <Image style={styles.avatar} source={{ uri: avatarUrl }} />
            <View style={styles.button}>
              <Text style={[styles.editText, SHEET.baseText]}>Edit Avatar</Text>
            </View>
          </View>
        </Button>

        <View style={[styles.buttonContainer, styles.editCoverButtonContainer]}>
          <Button onPress={() => { 
            if (!this.props.ddp.connected) { 
              return
            } 

            return this.__selectAndUploadImage.bind(this)({
              type: 'COVER_PIC', 
              stateKey: 'coverSource'})
          }}>
              <View style={styles.button}>
                <Text style={[styles.editText, SHEET.baseText]}>Edit Cover</Text>
              </View>
          </Button>
        </View>
      </TouchableOpacity>
    )
  }
}

var styles = StyleSheet.create({
  avatarContainer: {
    position: 'absolute',
    backgroundColor: 'rgba(0,0,0,0)', 
    left: width / 16,
    bottom: width / 16,
    width: width / 4,
  },
  avatar: {
    flex: 1,
    borderColor: 'white',
    borderWidth: 2.5,
    height: width / 4,
    borderRadius: width / 8,
  },
  editCoverButtonContainer: {
    position: 'absolute',
    right: width / 16,
    bottom: width / 16,
  },
  buttonContainer: {
    backgroundColor: 'rgba: (0,0,0,0)',
    borderWidth: 1,
    borderColor: 'white',
    alignItems: 'center',
    borderRadius: 2,
  },
  button: {
    width: width / 4,
    paddingVertical: 5,
  },
  editText: {
    flex: 1,
    color: 'white',
    textAlign: 'center',
    fontSize: 16
  },
  cover: {
    resizeMode: 'cover',
  },
  coverShadow: {
    backgroundColor: 'black',
    opacity: 0.5
  }
});

module.exports = EditMyPhotoHeader;