import React, {
  View,
  Text,
  Image,
  StyleSheet,
} from 'react-native';

import Loader from './Loader';
import { Card, TappableCard } from './Card';
import { SHEET }  from '../../CommonStyles';
import Routes from '../../nav/Routes';
import Analytics from '../../../modules/Analytics';

const logger = new (require('../../../modules/Logger'))('linkServiceCard');

function capitalizeFirstLetter(string) {
  return string.charAt(0).toUpperCase() + string.slice(1);
}

function renderCardInfo(iconUrl, status, serviceName, serviceUsername) {
  const actionItemIcon = (status == 'linked') ?
    <Image source={require('../img/ic-checkmark.png')} style={[SHEET.icon]} /> :
    <Image source={require('../img/ic-add.png')} style={[SHEET.icon]} />

  return (
    <View style={styles.service}>
      <Image source={{ uri: iconUrl }} style={[SHEET.icon]} />
      <View style={styles.serviceDesc}>
        <Text style={[SHEET.subTitle, SHEET.baseText]}>
          { capitalizeFirstLetter(serviceName) }
        </Text>
        { serviceUsername }
      </View>
      { actionItemIcon }
    </View>
  )
}

function linkSingleIntegrationCard(integration, onPressToLink) {
  console.log(integration);
  
  const { id, status, name, username, icon } = integration;

  // i.e. @fanghai44
  const serviceUsername = (status == 'linked') ?
    <Text style={[styles.serviceId, SHEET.baseText]}>{ username }</Text> : null;

  if (name == 'facebook' && status == 'linked') {
    // Special case: the user is not allowed to unlink Facebook once they link it.
    return (
      <Card key={id}>
        {renderCardInfo(icon.url, status, name, serviceUsername)}
      </Card>
    )
  }

  return (
    <TappableCard key={id} onPress={() => {
      if (integration.status === 'linked') {
        Analytics.track('Remove Integration', {
          name: integration.name
        })
      } else {
        Analytics.track('Add Integration', {
          name: integration.name
        })
      }
      return onPressToLink(integration.name, integration.url)
    }}>
      { renderCardInfo(icon.url, status, name, serviceUsername) }
    </TappableCard>
  )
}

function onLinkViaWebView(serviceName, url) {
  const capitalizedName = capitalizeFirstLetter(serviceName);
  const route = Routes.instance.getLinkViaWebView(capitalizedName, url);
  this.navigator.push(route);
}

export default function linkServiceCard(integrations, onLinkFacebook, navigator) {
  if (integrations.length == 0) {
    return <Loader />
  }

  return (
    <View style={styles.cards}>
      { integrations.map(integration => {
        const onPressToLink = integration.name == 'facebook' ?
          onLinkFacebook :
          onLinkViaWebView.bind({ navigator: navigator });
        return linkSingleIntegrationCard(integration, onPressToLink)
      }) }
    </View>
  )
}
var styles = StyleSheet.create({
  service: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
  },
  serviceDesc: {
    flex: 1,
    left: 15,
  },
  serviceId: {
    color: '#000000',
    fontSize: 15,
  },
  cards: {
    marginVertical: 5,
  },
})
