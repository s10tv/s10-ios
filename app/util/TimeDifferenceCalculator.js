class TimeDifferenceCalculator {
  static calculate(current, previous) {
    var msPerMinute = 60 * 1000;
    var msPerHour = msPerMinute * 60;
    var msPerDay = msPerHour * 24;
    var msPerWeek = msPerDay * 7;

    var elapsed = current - previous;

    if (elapsed < msPerHour) {
      return Math.round(elapsed/msPerMinute) + 'm';
    }

    else if (elapsed < msPerDay ) {
      return Math.round(elapsed/msPerHour ) + 'h';
    }

    else if (elapsed < msPerWeek) {
      return Math.round(elapsed/msPerDay) + 'd';
    }

    else {
      return Math.round(elapsed/msPerWeek) + 'w';
    }
  }
}

module.exports = TimeDifferenceCalculator;
