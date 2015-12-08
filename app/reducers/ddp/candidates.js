
function candidate(state = { loaded: false }, action) {
  switch (action.type) {
    case 'SET_ACTIVE_CANDIDATE':
      return Object.assign({}, state, action.candidate, {
        loaded: true
      });
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
