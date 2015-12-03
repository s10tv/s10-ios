class CWLChecker {

  constructor(store) {

  }

  checkCWL({
    version,
    currentVersion,
    showCWLForTestFlight,
    isRunningTestFlightBeta}) {

    // not a whitelisted version - need CWL
    if (version != currentVersion) {
      return true;
    }

    // running PROD on a whitelisted version - dont need CWL
    if (!isRunningTestFlightBeta) {
      return false;
    }

    // same version, running beta, needs to show CWL.
    if (showCWLForTestFlight) {
      return true;
    }

    // same version, running beta, don't show CWL
    return false;
  }
}

export { CWLChecker };
