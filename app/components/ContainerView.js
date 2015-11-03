'use strict';

var React = require('react-native');

class ContainerView extends React.Component {
  render() {
    return <TSContainerView {...this.props} />;
  }
}

ContainerView.propTypes = {
  sbName: React.PropTypes.string,
  vcIdentifier: React.PropTypes.string,
}

var TSContainerView = React.requireNativeComponent('TSContainerView', ContainerView);

module.exports = ContainerView
