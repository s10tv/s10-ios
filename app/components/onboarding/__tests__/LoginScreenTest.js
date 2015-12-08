/*
class MockReactComponent {
  constructor(props) {
    this.props = props;
  }
}

jest.setMock('react-native-fbsdklogin', {
  FBSDKLoginButton: {},
  FBSDKLoginManager: {},
});

jest.setMock('react-native-fbsdkcore', {
  FBSDKAccessToken: {
    getCurrentAccessToken: (callback) => callback(ACCESS_TOKEN)
  },
})

jest.setMock('react-redux/native', {
  connect: (stateMap) => (component) => component
})

jest.setMock('react-native', {
  Component: MockReactComponent,
  Text: MockReactComponent,
  View: MockReactComponent,
  StyleSheet: MockReactComponent,
})

jest.dontMock('../LoginScreen');
const LoginScreen = require('../LoginScreen');

const ACCESS_TOKEN = { tokenString: 'access-token' };
const LOGIN_RESULT = { token: 'token' };
const DISPATCH_FN = jest.genMockFunction();
const FB_HANDLER_LOGIN_FN = jest.genMockFunction();
const ON_PRESS_LOGIN_FN = jest.genMockFunction();

describe('LoginScreen', () => {

  beforeEach(() => {
    FB_HANDLER_LOGIN_FN.mockReturnValue(Promise.resolve(LOGIN_RESULT))
  })

  describe('onFacebookLogin', () => {
    it('should dispatch an action if there is an error', () => {
      try {
        new LoginScreen({ dispatch: DISPATCH_FN }).onFacebookLogin('fb-login-error', null);
        fail('should not proceed if there was an error')
      } catch(err) {
        expect(DISPATCH_FN.mock.calls.length).toEqual(1);
        let [[{ type, title, message }]] = DISPATCH_FN.mock.calls;
        expect(type).toEqual('DISPLAY_ERROR');
        expect(title).toMatch(/\s+/)
        expect(message).toMatch(/\s+/)
      }
    })

    pit('should ultimately call onPressLogin in successful case', () => {
      const handler = new LoginScreen({
        dispatch: DISPATCH_FN,
        onPressLogin: ON_PRESS_LOGIN_FN,
      });

      handler.facebookLoginHandler = {
        onLogin: FB_HANDLER_LOGIN_FN
      };

      return handler.onFacebookLogin(null, {})
      .then(() => {
        expect(handler.facebookLoginHandler.onLogin.mock.calls.length).toEqual(1);
        const [[ accessToken ]] = handler.facebookLoginHandler.onLogin.mock.calls;
        expect(accessToken).toEqual(ACCESS_TOKEN.tokenString);

        expect(ON_PRESS_LOGIN_FN.mock.calls.length).toEqual(1);
        const [[ loginResult ]] = ON_PRESS_LOGIN_FN.mock.calls;
        expect(loginResult).toEqual(LOGIN_RESULT);
      })
    })
  })
})
*/
