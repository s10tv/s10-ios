let React = require('react-native');

let {
  AppRegistry,
  View,
  TabBarIOS,
} = React;

let OnboardingNavigator = require('./onboarding/OnboardingNavigator');
let MeNavigator = require('./me/MeNavigator');
let DiscoverNavigator = require('./discover/DiscoverNavigator');
let Loader = require('./lib/Loader');

let TSDDPClient = require('../lib/ddpclient');

let SHEET = require('./CommonStyles').SHEET;

class LayoutContainer extends React.Component {

  constructor(props: {}) {
    super(props);
    this.ddp = new TSDDPClient(props.wsurl);

    this.subs = {}

    this.state = {
      needsOnboarding: true,
      modalVisible: false,
      currentTab: 'me',
    }
  }

  onLogin() {
    let ddp = this.ddp;
    this.setState({ loggedIn: true });

    console.log('onlogin called .. ');

    this.ddp.subscribe({ pubName: 'settings' })
    .then(() => {
      ddp.collections.observe(() => {
        if (ddp.collections.settings) {
          return ddp.collections.settings.find({});
        }
      }).subscribe(settings => {
        indexedSettings =  {};
        settings.forEach((setting) => {
          indexedSettings[setting._id] = setting;
        });
        this.setState({ settings: indexedSettings });
      });
    });

    this.ddp.subscribe({ pubName: 'me' })
    .then(() => {
      ddp.collections.observe(() => {
        if (ddp.collections.users) {
          return ddp.collections.users.findOne({ _id: ddp.currentUserId });
        }
      }).subscribe(currentUser => {
        this.setState({ me: currentUser });
      });

      ddp.collections.observe(() => {
        if (ddp.collections.users) {
          return ddp.collections.users.find({});
        }
      }).subscribe(users => {
        this.setState({ users: users });
      });
    });

    this.ddp.subscribe({ pubName: 'integrations' })
    .then(() => {
      ddp.collections.observe(() => {
        if (ddp.collections.integrations) {
          return ddp.collections.integrations.find({});
        }
      }).subscribe(integrations=> {
        integrations.sort((one, two) => {
          return one.status == 'linked' ? -1 : 1;
        })
        this.setState({ integrations: integrations });
      });
    });

    this.ddp.subscribe({ pubName: 'hashtag-categories' })
    .then(() => {
      ddp.collections.observe(() => {
        if (ddp.collections.categories) {
          return ddp.collections.categories.find({});
        }
      }).subscribe(categories=> {
        this.setState({ categories: categories });
      });
    });

    this.ddp.subscribe({ pubName: 'my-tags' })
    .then(() => {
      ddp.collections.observe(() => {
        if (ddp.collections.mytags) {
          return ddp.collections.mytags.findOne({});
        }
      }).subscribe(user => {
        user.tags.forEach((tag) => {
          tag.isMine = true;
        })
        this.setState({ myTags: user.tags });
      });
    });

    this.ddp.subscribe({ pubName: 'candidate-discover' })
    .then(() => {
      ddp.collections.observe(() => {
        if (ddp.collections.candidates) {
          return ddp.collections.candidates.find({});
        }
      }).subscribe(candidates => {
        let activeCandidates = candidates.filter((candidate) => {
          return candidate.type == 'active'
        })

        if (activeCandidates.length > 0) {
          this.setState({ candidate: activeCandidates[0] })
        }

        this.setState({ candidates: candidates });
      });
    });

    this.ddp.subscribe({ pubName: 'activities', params:[ddp.currentUserId] })
    .then(() => {
      ddp.collections.observe(() => {
        if (ddp.collections.activities) {
          return ddp.collections.activities.find({ userId: ddp.currentUserId });
        }
      }).subscribe(activities => {
        this.setState({ myActivities: activities });
      });
    });
  }

  componentWillMount() {
    let ddp = this.ddp;

    ddp.initialize()
    .then(() => {
      return ddp.loginWithToken(); 
    }).then((res) => {
      this.setState(res);
      if (res.loggedIn) {
        this.onLogin();
      }
    })
  }

  render() {
    if (!this.state.loggedIn) {
      return <OnboardingNavigator
        loggedIn={this.state.loggedIn}
        onLogin={this.onLogin.bind(this)}
        ddp={this.ddp} /> 
    }

    console.log('logged in is true?');

    if (!this.state.settings) {
      return <Loader />
    }
    let status = this.state.settings.accountStatus.value;

    console.log(status);
    if (status != 'active') {
      return <OnboardingNavigator
        me={this.state.me} 
        loggedIn={this.state.loggedIn}
        integrations={this.state.integrations}
        categories={this.state.categories}
        myTags={this.state.myTags}
        ddp={this.ddp} />
    } else {
       return (
          <TabBarIOS>
            <TabBarIOS.Item 
              title="Me"
              icon={require('./img/ic-me.png')}
              onPress={() => {
                this.setState({currentTab: 'me'});
              }}
              selected={this.state.currentTab == 'me'}>
              
              <MeNavigator ddp={this.ddp}
                me={this.state.me}
                myActivities={this.state.myActivities}
                categories={this.state.categories}
                myTags={this.state.myTags}
                integrations={this.state.integrations}/>

            </TabBarIOS.Item>
            <TabBarIOS.Item 
              title="Discover"
              icon={require('./img/ic-compass.png')}
              onPress={() => {
                this.setState({currentTab: 'discover'});
              }}
              selected={this.state.currentTab == 'discover'}>

              <DiscoverNavigator ddp={this.ddp}
                me={this.state.me}
                candidate={this.state.candidate}
                settings={this.state.settings}
                users={this.state.users} />

            </TabBarIOS.Item>
            <TabBarIOS.Item 
              title="Chats"
              icon={require('./img/ic-chats.png')}
              onPress={() => {
                this.setState({currentTab: 'chats'});
              }}
              selected={this.state.currentTab == 'chats'}>
                <View />
            </TabBarIOS.Item>
          </TabBarIOS>
      )
    }
  }
}

module.exports = LayoutContainer;