function showOverlayLoader(state = false, action) {
  switch (action.type) {
    case 'UPLOAD_START':
      return true;

    case 'UPLOAD_FINISH':
      return false

    default:
      return state;
  }
}

/*
Action should look like this:

{ visible: true,
  title: 'hello',
  message: 'yes',
  buttons:[
    { text: 'qiming', action: null },
    { text: 'yes', action: null }
  ]
};

only supports 1 or 2 buttons. If no buttons are provided, then 'okay' button will be rendered.
*/

const defaultDialogState = { visible: false }
function dialog(state = defaultDialogState, action) {
  switch (action.type) {
    case 'DISPLAY_POPUP_MESSAGE':
      return Object.assign({}, state, action.dialog);

    case 'DISPLAY_ERROR':
      return Object.assign({}, state, {
        title: action.title,
        message: action.message,
        buttons: null, // will default to 'okay button'
      })

    case 'CLOSE_DIALOG':
      return defaultDialogState;

    default:
      return state;
  }
}

export {
  showOverlayLoader,
  dialog,
}
