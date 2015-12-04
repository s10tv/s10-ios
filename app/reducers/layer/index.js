import { combineReducers } from 'redux';

function allConversationCount(state = 0 , action) {
  switch (action.type) {
    case 'CHANGE_ALL_COUNT':
      return action.count
    default:
      return state;
  }
}

function unreadConversationCount(state = 0 , action) {
  switch (action.type) {
    case 'CHANGE_UNREAD_COUNT':
      return action.count
    default:
      return state;
  }
}

module.exports = combineReducers({
  allConversationCount,
  unreadConversationCount,
})
