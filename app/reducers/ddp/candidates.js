const defaultCandidate = { loaded: false };

function candidate(state = defaultCandidate, action) {
  switch (action.type) {
    case 'SET_ACTIVE_CANDIDATE':
      return Object.assign({}, state, action.candidate, {
        loaded: true
      });

    case 'LOGOUT':
      return defaultCandidate;

    default:
      return state;
  }
}

function pastCandidates(state = [], action) {
  switch (action.type) {
    case 'SET_HISTORY_CANDIDATE':
      return action.candidates;

    case 'LOGOUT':
      return []

    default:
      return state;
  }
}

export {
  candidate,
  pastCandidates,
}
