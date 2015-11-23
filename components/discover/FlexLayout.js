var React = require('react-native');
var {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  Image,
  ScrollView
} = React;

var Profile = React.createClass({
    render: function() {
        return (
            <View style={[styles.imgContainer, {height: this.props.containerHeight}]}>
                <Image source={{uri:this.props.imageURL}} style={[styles.images, {height: this.props.containerHeight}]}/>
            </View>
        );
    }
});

var FlexLayout = React.createClass({
    _shuffle: function(o){
        for(var j, x, i = o.length; i; j = Math.floor(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x);
        return o;
    },
    createProfiles: function(candidates) {
        let datas = candidates.map((candidate) => {
          let user = this.props.ddp.collections.users.findOne({ _id: candidate.userId });
          return { url: user.avatar.url }
        });

        var heights = [200, 180, 150];

        return this._shuffle(datas).map(function (profile, i) {
            var randomHeight = Math.floor(Math.random() * (4 - 0));
            var height = this._shuffle(heights)[randomHeight];
            return <Profile imageURL={profile.url} containerHeight={height} key={i}/>;
        }.bind(this))
    },
  render: function() {
    return (
        <ScrollView style={styles.scrollStyle}>
          <View style={styles.wrapper}>
              <View style={styles.row}>
                {this.createProfiles(this.props.candidates)}
              </View>

              <View style={[styles.row, {marginRight: 0}]}>
                {this.createProfiles(this.props.candidates)}
              </View>
          </View>
        </ScrollView>
    );
  }
});

var styles = StyleSheet.create({
  scrollStyle: {
    flex: 1,
    paddingTop: 64,
  },
  wrapper: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginRight: 5,
    marginLeft: 5
  },
  row: {
    flex: 1,
    flexDirection: 'column',
    flexWrap: 'wrap',
    marginRight: 5
  },
  imgContainer: {
    height: 200,
    marginBottom: 6
  },
  images: {
    flex: 1,
    resizeMode: 'cover'
  }
});

module.exports = FlexLayout;