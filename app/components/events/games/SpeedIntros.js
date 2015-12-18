import React, {
  Dimensions,
  View,
  Image,
  Text,
  ScrollView,
  StyleSheet,
} from 'react-native';

import { connect } from 'react-redux/native';

import Loader from '../../lib/Loader';
import { SHEET } from '../../../CommonStyles';
import { TappableCard } from '../../lib/Card';
import HeaderBanner from '../../lib/HeaderBanner';
import Routes from '../../../nav/Routes';

const { width, height } = Dimensions.get('window');

function mapStateToProps(state) {
  return {
    ddp: state.ddp
  }
}

class SpeedIntros extends React.Component {

  constructor(props = {}) {
    super(props);
    this.state = {}
  }

  componentWillMount() {
    this.props.ddp.subscribe({ pubName: 'speedintro-event', params: [this.props.eventId] })
    .then((subId) => {
      this.subId = subId;

      this.observer = this.props.ddp.collections.observe(() => {
        return this.props.ddp.collections.speedintros.find({ type: 'active' });
      }).subscribe(intros => {
        if (intros.length > 0) {
          const [currentIntro] = intros;

          currentIntro.user = this.props.ddp._formatUser(currentIntro.user);
          this.setState({ currentIntro: currentIntro });
        }
      });
    })
  }

  componentWillUnmount() {
    if (this.subId) {
      this.props.ddp.unsubscribe(this.subId);
    }

    if (this.observer) {
      this.observer.dispose()
    }
  }

  render() {
    if (!this.state.currentIntro) {
      return <Loader />
    }

    const intro = this.state.currentIntro;
    const user = intro.user;

    return (
      <View style={SHEET.container}>
        <ScrollView>
          <TappableCard style={SHEET.innerContainer} onPress={() => {
            const route = Routes.instance.getProfileRoute({
              user: user,
              isEditable: false,
            });

            this.props.navigator.parentNavigator.push(route);
          }}>
            <View>
              <HeaderBanner url={user.coverUrl} height={height / 2.5} roundTopCorners={true}>
                <View style={[styles.header, { borderRadius: 10, borderColor: 'transparent'}]}>
                  <Image source={{ uri: user.avatarUrl }} style={styles.avatar} />
                </View>
                <View style={[styles.header, { borderRadius: 10, borderColor: 'transparent'}]}>
                  <Image source={{ uri: user.avatarUrl }} style={styles.avatar} />
                </View>

                <View style={styles.bottomInfo}>
                  <View style={styles.userInfo}>
                    <Text style={[styles.userNameText, SHEET.baseText]}>
                      { user.displayName }
                    </Text>
                  </View>
                </View>
              </HeaderBanner>

              <Text style={styles.description}>{ intro.description }</Text>
            </View>
          </TappableCard>
        </ScrollView>
      </View>
    )
  }
}

let avatarRadius = height / 4.5;

var styles = StyleSheet.create({
  avatar: {
    borderWidth: 2.5,
    borderColor: 'white',
    borderRadius: avatarRadius / 2,
    height: avatarRadius,
    width: avatarRadius,
  },
  header: {
    position: 'absolute',
    backgroundColor: 'rgba(0,0,0,0)',
    top: 0,
    left: 0,
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'center',
    width: width,
    height: height / 2.5,
  },
  userInfo: {
    flex: 1,
  },
  serviceInfo: {
    height: 42,
    justifyContent: 'center',
    flexDirection: 'row',
  },
  description: {
    marginTop: 15,
  },
  bottomInfo: {
    position: 'absolute',
    bottom: 0,
    width: width,
    flexDirection: 'row',
    backgroundColor: 'transparent',
    paddingHorizontal: width / 32,
    paddingVertical: 5,
  },
  userNameText: {
    color: 'white',
    fontSize: 24,
  },
})

export default connect(mapStateToProps)(SpeedIntros)
