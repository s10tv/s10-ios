jest.dontMock('../ResumeTokenHandler');
let ResumeTokenHandler = require('../ResumeTokenHandler');

describe('ResumeTokenHandler', () => {

  const DISPATCH_FN = jest.genMockFunction();

  let ddp;
  let session;
  let handler;

  function assertNoDispatch(expectedErr = handler.errors.COULD_NOT_LOG_IN) {
    return handler.handle(DISPATCH_FN).then((val) => {
      fail('should not have succeeded');
    }).catch(err => {
      expect(DISPATCH_FN.mock.calls.length).toEqual(0);
      expect(err).toBe(expectedErr);
    })
  }

  function assertDispatch() {
    const calls = DISPATCH_FN.mock.calls;
    expect(calls.length).toEqual(1);

    const [[{ type, userId, resumeToken }]] = calls;
    expect(type).toEqual('LOGIN_FROM_RESUME')
    expect(userId).toEqual('userId')
    expect(resumeToken).toEqual('token')
  }

  function assertDispatchedLogout() {
    return handler.handle(DISPATCH_FN).then((val) => {
      fail('should not have succeeded');
    }).catch(err => {
      const calls = DISPATCH_FN.mock.calls;
      expect(calls.length).toEqual(1);
      const [[{ type, userId, resumeToken }]] = calls;
      expect(type).toEqual('LOGOUT')
    })
  }

  beforeEach(() => {
    DISPATCH_FN.mockClear();
  })

  describe('when there is faulty network', () => {
    beforeEach(() => {
      ddp = {
        connected: false,
      };

      handler = new ResumeTokenHandler(ddp, {});
    })

    pit('should not have dispatched', () => {
      return assertNoDispatch(handler.errors.NO_NETWORK)
    })
  });

  describe('when the network is not faulty', () => {
    beforeEach(() => {
      ddp = {
        connected: true,
        loginWithToken: (resumeToken) => Promise.resolve({ resumeToken }),
        subscribe: () => Promise.resolve(),
      };
    })

    describe('user does not have stored resume token', () => {

      pit('should not dispatch if session is undefined', () => {
        handler = new ResumeTokenHandler(ddp, undefined);
        return assertDispatchedLogout()
      })

      pit('should not dispatch if userId not present', () => {
        handler = new ResumeTokenHandler(ddp,  { initialValue: () => { return {}}});
        return assertDispatchedLogout()
      })
    })

    describe('user has stored resume token', () => {

      beforeEach(() => {
        session = { initialValue: () => { return { resumeToken: 'token', userId: 'userId' }}};
        handler = new ResumeTokenHandler(ddp, session);
      })

      describe('resume token is expired', () => {
        pit('should not dispatch', () => {
          ddp.loginWithToken = () => Promise.resolve({});
          ddp.subscribe = () => Promise.reject('should not subscribe');

          return handler.handle(DISPATCH_FN).then((val) => {
            // we optimistically dispatched
          }).catch(err => {
            assertDispatch()
            expect(err).toBe(handler.errors.COULD_NOT_LOG_IN);
          })
        })
      })

      describe('resume token is valid', () => {
        pit('should dispatch LOGIN_FROM_RESUME', () => {
          return handler.handle(DISPATCH_FN).then(() => {
            const calls = DISPATCH_FN.mock.calls;
            expect(calls.length).toEqual(2);

            const [[ callone ], [calltwo]] = calls;
            let { type, userId, resumeToken } = callone;
            expect(type).toEqual('LOGIN_FROM_RESUME')
            expect(userId).toEqual('userId')
            expect(resumeToken).toEqual('token')

            expect(calltwo.type).toEqual('SET_IS_ACTIVE')
          })
        })
      })
    })

    describe('user originally NOT logged in from resume token', () => {

    })
  })
})
