
function candidate(state = null, action) {
  switch (action.type) {
    case 'SET_ACTIVE_CANDIDATE':
      return Object.assign({}, state, action.candidate);
    default:
      return state;
  }
}

function pastCandidates(state = [], action) {
  switch (action.type) {
    case 'SET_HISTORY_CANDIDATE':
      return action.candidates;
    default:
      return state;
  }
}

export {
  candidate,
  pastCandidates,
}
