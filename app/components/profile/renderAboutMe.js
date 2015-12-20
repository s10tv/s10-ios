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

function hasAllRequiredFields(user) {
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
  let majorAndGradYearSection = null;
  let editInfoButton = null;

  if (isEditable) {
    const editInfoButtonImage = hasAllRequiredFields(user) ?
        require('../img/ic-checkmark.png') :
        require('../img/ic-add.png');

    let name;
    if (user.firstName && user.lastName) {
      name = `${user.firstName} ${user.lastName}`;
    } else if (user.firstName) {
      name = user.firstName;
    } else if (user.lastName) {
      name = user.lastName;
    } else {
      name = '';
    }

    nameSection = iconTextRow(require('../img/ic-me-dark.png'), name);
    majorAndGradYearSection = iconTextRow(require('../img/ic-mortar.png'), `${user.major} ${user.gradYear}`);
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
          { majorAndGradYearSection }
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
    marginTop: 0,
    borderRadius: 3,
    paddingVertical: 3,
  },
  infoSection: {
    flex: 1
  },
});
