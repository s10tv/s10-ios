let React = require('react-native');
let TSLogger = React.NativeModules.TSLogger;

class Logger {

  constructor(callerInstanceOrDomain) {
    if (typeof callerInstanceOrDomain == 'string') {
      this.domain = callerInstanceOrDomain;
    } else if (callerInstanceOrDomain != null) {
      this.domain = callerInstanceOrDomain.constructor.name;
    } else {
      this.domain = '';
    }
    this.logToConsole = false;
  }

  verbose(message) {
    if (this.logToConsole) {
     console.log(message);
    }
    TSLogger.log(message, 'verbose', this.domain, '', '', 0);
  }

  debug(message) {
    if (this.logToConsole) {
     console.log(message);
    }
    TSLogger.log(message, 'debug', this.domain, '', '', 0);
  }

  info(message) {
    if (this.logToConsole) {
     console.info(message);
    }
    TSLogger.log(message, 'info', this.domain, '', '', 0);
  }

  warning(message) {
    if (this.logToConsole) {
     console.warn(message);
    }
    TSLogger.log(message, 'warn', this.domain, '', '', 0);
  }

  error(messageOrError) {
    // We'll let error logs go to console intentionally
    console.error(messageOrError);
    let message = messageOrError;
    if (typeof messageOrError != 'string') {
      message = JSON.stringify(message);
    }
    TSLogger.log(message, 'error', this.domain, '', '', 0);
  }

}

module.exports = Logger;
