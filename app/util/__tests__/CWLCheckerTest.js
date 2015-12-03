jest.dontMock('../CWLChecker');
let CWLChecker = require('../CWLChecker');

describe('CWLChecker', () => {

  describe('running in app store', () => {
    it('needs CWL if version not whitelisted', () => {
      var options = {
        version: 10,
        currentVersion: 25,
      };

      expect(new CWLChecker().checkCWL(options)).toEqual(true);
    });

    it('does not need CWL if version whitelisted', () => {
      var options = {
        version: 10,
        currentVersion: 10,
      };

      expect(new CWLChecker().checkCWL(options)).toEqual(false);
    })
  });

  describe('running in testflight', () => {
    let options = {};
    beforeEach(() => {
      options.isRunningTestFlightBeta = true;
    })

    describe('when current version matches whitelisted version', () => {
      beforeEach(() => {
        options.version = 10;
        options.currentVersion = 10;
      });

      it('dont need CWL if showCWLForTestFlight is not set', () => {
        expect(new CWLChecker().checkCWL(options)).toEqual(false);
      });

      it('needs CWL if showCWLForTestFlight is set to true', () => {
        options.showCWLForTestFlight = true;
        expect(new CWLChecker().checkCWL(options)).toEqual(true);
      });

      it('does not need CWL if showCWLForTestFlight is set to false', () => {
        options.showCWLForTestFlight = false;
        expect(new CWLChecker().checkCWL(options)).toEqual(false);
      });
    })

    describe('when current version does not match the whitelisted version', () => {
      beforeEach(() => {
        options.version = 10;
        options.currentVersion = 25;
      });

      it('needs CWL', () => {
        expect(new CWLChecker().checkCWL(options)).toEqual(true);
      })
    });
  });
});
