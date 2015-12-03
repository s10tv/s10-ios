jest.dontMock('../ResumeTokenHandler');
let ResumeTokenHandler = require('../ResumeTokenHandler');

describe('ResumeTokenHandler', () => {

  const DISPATCH_FN = jest.genMockFunction();

  let ddp;
  let session;
  let handler;

  function assertNoDispatch() {
    return handler.handle(DISPATCH_FN).then((val) => {
      expect(DISPATCH_FN.mock.calls.length).toEqual(0);
      expect(val).toEqual(false)
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

  beforeEach(() => {
    DISPATCH_FN.mockClear();
  })

  describe('when there is faulty network', () => {
    beforeEach(() => {
      ddp = {
        connected: false,
        initialize: () => Promise.resolve(),
      };

      handler = new ResumeTokenHandler(ddp, {});
    })

    pit('should not have dispatched', () => {
      return assertNoDispatch()
    })
  });

  describe('when the network is not faulty', () => {
    beforeEach(() => {
      ddp = {
        connected: true,
        initialize: () => Promise.resolve(),
        loginWithToken: (resumeToken) => Promise.resolve({ resumeToken }),
        subscribe: () => Promise.resolve(),
      };
    })

    describe('user does not have stored resume token', () => {

      pit('should not dispatch if session is undefined', () => {
        handler = new ResumeTokenHandler(ddp, undefined);
        return assertNoDispatch()
      })

      pit('should not dispatch if userId not present', () => {
        handler = new ResumeTokenHandler(ddp, undefined);
        return assertNoDispatch()
      })

      pit('should not dispatch if userId not present', () => {
        handler = new ResumeTokenHandler(ddp, undefined);
        return assertNoDispatch()
      })
    })

    describe('user has stored resume token', () => {

      beforeEach(() => {
        session = { initialValue: { resumeToken: 'token', userId: 'userId' }};
        handler = new ResumeTokenHandler(ddp, session);
      })

      describe('resume token is expired', () => {
        pit('should not dispatch', () => {
          ddp.loginWithToken = () => Promise.resolve({});
          ddp.subscribe = () => Promise.reject('should not subscribe');

          return handler.handle(DISPATCH_FN).then((val) => {
            // we optimistically dispatched
            assertDispatch()
            expect(val).toBe(false);
          })
        })
      })

      describe('resume token is valid', () => {
        pit('should dispatch LOGIN_FROM_RESUME', () => {
          return handler.handle(DISPATCH_FN).then(() => {
              assertDispatch();
          })
        })
      })
    })

    describe('user originally NOT logged in from resume token', () => {

    })
  })
})
