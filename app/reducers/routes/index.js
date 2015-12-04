import { combineReducers } from 'redux';

import root from './root'
import onboarding from './onboarding'
import fullscreen from './fullscreen'

module.exports = combineReducers({
  root,
  onboarding,
  fullscreen,
})
