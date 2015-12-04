import React, {
  View,
} from 'react-native';

let RootRouter = {
  root() {
    return {
      // You can also render a scene yourself when you need more control over
      // the props of the scene component
      renderScene(navigator) {
        let DiscoverScreen = require('./components/discover/DiscoverScreen');
        return <DiscoverScreen navigator={navigator} />;
      },

      getTitle() {
        return 'Today'
      },
    };
  },
}

module.exports = RootRouter;
