import React, {
  View,
  Text,
  Image,
  StyleSheet,
  TouchableOpacity,
  Dimensions
} from 'react-native';

import { TappableCard } from '../lib/Card';
import { SHEET, COLORS } from '../../CommonStyles'
import moment from 'moment';
const logger = new (require('../../../modules/Logger'))('eventsCommon');
const { width, height } = Dimensions.get('window');

export function renderEventCard(event, onPress, hideDetailButton = false, styleOverride) {
  var detailButton = hideDetailButton ? null :
    (
      <TouchableOpacity onPress={onPress} style={styles.arrowRightButton}>
        <Image style={styles.arrowRightIcon} source={require('../img/ic-right-arrow.png')}/>
      </TouchableOpacity>
    )
  return (
    <TappableCard
      style={[styles.card, styleOverride]}
      hideSeparator={true}
      key={event._id}
      onPress={onPress}
      cardOverride={{ padding: 10 }}>
      <View style={styles.cardContainer}>
        <View style={styles.cardUpperContainer}>
          <View style={styles.cardUpperContainerLeftContent}>
            <View style={styles.eventTitleContainer}>
              <Image source={require('../img/ic-calendar.png')} style={styles.calendarIcon} />
              <Text style={[SHEET.baseText, styles.eventTitleText]}>{event.title}</Text>
            </View>
            <Text style={[SHEET.baseText, styles.eventDescText]}>{event.desc}</Text>
          </View>
          { detailButton }
        </View>
        <View style={[SHEET.separator, { marginTop: 10 }]} />
        <View style={styles.eventDetailContainer}>
          <Image style={styles.clockIcon} source={require('../img/ic-clock.png')} />
          <Text style={[SHEET.baseText, styles.eventTimeText]}>{moment(event.startTime).format('h:m a, MMMM D, YYYY')}</Text>
        </View>
        <View style={styles.eventDetailContainer}>
          <Image style={styles.pinIcon} source={require('../img/ic-pin.png')} />
          <Text style={[SHEET.baseText, styles.eventLocationText]}>{event.location}</Text>
        </View>
      </View>
    </TappableCard>
  )
}

var styles = StyleSheet.create({
  card: {
    marginBottom: 10,
    padding: 1,
    borderRadius: 3,
  },
  cardContainer: {
    flexDirection: 'column',
  },
  cardUpperContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  cardUpperContainerLeftContent: {
    flexDirection: 'column',
  },
  eventTitleContainer: {
    flexDirection: 'row',
  },
  eventDetailContainer: {
    flexDirection: 'row',
    marginTop: 10,
  },
  arrowRightButton: {
    alignSelf: 'center',
    marginRight: 6,
  },
  eventTitleText: {
    fontSize: 16,
    marginLeft: 7,
  },
  eventDescText: {
    fontSize: 11,
    marginTop: 10,
    width: width / 1.2
  },
  eventTimeText: {
    marginLeft: 10,
    fontSize: 12,
  },
  eventLocationText: {
    marginLeft: 12,
    fontSize: 12,
  },
  calendarIcon: {
    width: 19,
    height: 20,
  },
  arrowRightIcon: {
    width: 9,
    height: 15,
  },
  clockIcon: {
    width: 15,
    height: 15,
  },
  pinIcon: {
    marginLeft: 1,
    width: 12,
    height: 18,
  },
});
