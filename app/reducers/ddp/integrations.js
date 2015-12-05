const logger = new (require('../../../modules/Logger'))('IntegrationsReducer');

export default function integrations(state = [], action) {
  switch (action.type) {
    case 'SET_INTEGRATIONS':
      return Object.assign({}, state, action.integrations);

    default:
      return state;
  }
}
