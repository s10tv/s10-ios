jest.dontMock('../ResumeTokenHandler');
let ResumeTokenHandler = require('../ResumeTokenHandler');

describe('ResumeTokenHandler', () => {

  const DISPATCH_FN = jest.genMockFunction();

  let ddp;
  let session;
  let handler;

  beforeEach(() => {
    ddp = {
      connected: true,
      initialize: () => Promise.resolve(),
      loginWithToken: (resumeToken) => Promise.resolve({ resumeToken }),
      subscribe: () => Promise.resolve(),
    };
  })

  describe('user is logged in from resume token', () => {
    beforeEach(() => {
      session = { initialValue: { resumeToken: 'token', userId: 'userId' }};
      handler = new ResumeTokenHandler(ddp, session);
    })

    pit('should dispatch LOGIN_FROM_RESUME', () => {
      return handler.handle(DISPATCH_FN).then(() => {
        const calls = DISPATCH_FN.mock.calls;
        expect(calls.length).toEqual(1);

        const [[{ type, userId, resumeToken }]] = calls;
        expect(type).toEqual('LOGIN_FROM_RESUME')
        expect(userId).toEqual('userId')
        expect(resumeToken).toEqual('token')
      })
    })
  })

  describe('user is NOT logged in from resume token', () => {

  })
})
