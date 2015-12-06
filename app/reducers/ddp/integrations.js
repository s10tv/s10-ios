const logger = new (require('../../../modules/Logger'))('IntegrationsReducer');

export default function integrations(state = [], action) {
  switch (action.type) {
    case 'SET_INTEGRATIONS':
      logger.debug(`[integrations]: redux got ${action.integrations.length} integrations`)

      // TODO(qimingfang): better merge these arrays using Array.reduce.
      return action.integrations;

    default:
      return state;
  }
}
