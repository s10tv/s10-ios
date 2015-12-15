import React, {
  View,
  Text,
  Image,
  TouchableOpacity,
  StyleSheet,
} from 'react-native';

import { Card } from '../lib/Card';
import sectionTitle from '../lib/sectionTitle';
import iconTextRow from '../lib/iconTextRow';
import Routes from '../../nav/Routes';
import { SHEET } from '../../CommonStyles';

function hasOneRequiredField(user, field) {
  return user[field] && user[field].length > 0;
}

function hasALlRequiredFields(user) {
  return ['firstName', 'lastName', 'hometown', 'major', 'gradYear'].reduce((acc, ele) => {
    return acc && hasOneRequiredField(user, ele);
  }, true);
}

export default function renderAboutMe({ user, onPressEdit, isEditable = false }) {
  const aboutSection = !user.about ? null : (
    <View>
      <View style={SHEET.separator} />
      <View style={{ marginTop: 10 }}>
        <Text stlye={[SHEET.baseText]}>{user.about}</Text>
      </View>
    </View>
  )

  let nameSection = null;
  let gradYearSection = null;
  let editInfoButton = null;

  if (isEditable) {
    const editInfoButtonImage = hasALlRequiredFields(user) ?
        require('../img/ic-checkmark.png') :
        require('../img/ic-add.png');

    nameSection = iconTextRow(require('../img/ic-me-dark.png'), `${user.firstName} ${user.lastName}`);
    gradYearSection = iconTextRow(require('../img/ic-mortar.png'), user.gradYear);
    editInfoButton = (
      <TouchableOpacity onPress={onPressEdit}>
        <Image source={editInfoButtonImage} style={[SHEET.iconCircle, styles.icon]} />
      </TouchableOpacity>
    );
  }

  return (
    <View style={SHEET.innerContainer}>
      { sectionTitle('ABOUT') }
      <Card
          hideSeparator={true}
          style={[styles.card]}
          cardOverride={{flexDirection: 'row', paddingVertical: 5, paddingHorizontal: 10}}>

        <View style={styles.infoSection}>
          { nameSection }
          { gradYearSection }
          {iconTextRow(require('../img/ic-mortar.png'), user.major)}
          {iconTextRow(require('../img/ic-house.png'), user.hometown)}

          { aboutSection }
        </View>
        { editInfoButton }
      </Card>
    </View>
  )
}


var styles = StyleSheet.create({
  card: {
    flex: 1,
    marginTop: 8,
    borderRadius: 3,
    paddingVertical: 3,
  },
  infoSection: {
    flex: 1
  },
});
