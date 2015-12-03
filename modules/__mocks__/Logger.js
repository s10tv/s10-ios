class MockLogger {
  constructor() {
    this.messages = {
      warning: [],
      error: [],
      debug: [],
    };
  }

  warning(message) {
    this.messages.warning.push(message);
  }

  debug(message) {
    this.messages.debug.push(message);
  }

  error(message) {
    throw new Error(message);
  }
}

module.exports = MockLogger;
