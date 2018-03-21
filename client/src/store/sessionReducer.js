import { createAction, createReducer } from 'redux-act'
import axios from 'axios'
import config from 'config/app-config.json'

// ------------------------------------
// Actions
// ------------------------------------
export const clearError = createAction('clear any error message')
export const loginSuccess = createAction('successful login')
export const loginFail = createAction('failed login')
export const logoutSuccess = createAction('logout')
export const startUserSession = createAction('start user session')
export const updateUser = createAction('UPDATE_USER')

export const authorizeInstagramUser = (authCode) =>
  dispatch =>
    axios({
      method: 'POST',
      url: 'oauth/callback',
      // headers: {
      //   'X-User-Email': getState().session.userInfo.email,
      //   'X-User-Token': getState().session.userInfo.authToken
      // },
      data: { code: authCode }
    })
    .then(res => {
      setInfoInLocalStorage(res.data.user.authentication_token, res.data.user.email, res.data.user.username)
      dispatch(loginSuccess(res.data.user))
      Promise.resolve()
    })
    .catch(err => console.error('logout error', err))

export const login = (user) =>
  dispatch =>
    axios({
      method: 'POST',
      url: `${config.apiBase}/user/sign_in`,
      data: { user }
    })
    .then(res => {
      setInfoInLocalStorage(res.data.user.authentication_token, res.data.user.email, res.data.user.username)
      dispatch(loginSuccess(res.data.user))
      Promise.resolve()
    })
    .catch(err => Promise.reject(dispatch(loginFail(err))))

export const logout = () =>
  (dispatch, getState) => {
    removeInfoInLocalStorage()
    return axios({
      method: 'DELETE',
      url: `${config.apiBase}/user/sign_out`,
      headers: {
        'X-User-Username': getState().session.userInfo.username,
        'X-User-Token': getState().session.userInfo.authToken
      }
    })
    .then(() => {
      dispatch(logoutSuccess())
      Promise.resolve()
    })
    .catch(err => console.error('logout error', err))
  }

export const register = (user) =>
  dispatch =>
    axios({
      method: 'POST',
      url: `${config.apiBase}/user`,
      data: { user }
    })
    .then(res => {
      setInfoInLocalStorage(res.data.user.authentication_token, res.data.user.email, res.data.user.username)
      dispatch(loginSuccess(res.data.user))
      Promise.resolve()
    })
    .catch(err => Promise.reject(dispatch(loginFail(err))))

function setInfoInLocalStorage (token, email, username) {
  localStorage.setItem('authToken', token)
  localStorage.setItem('email', email)
  localStorage.setItem('username', username)
}

function removeInfoInLocalStorage () {
  localStorage.removeItem('authToken')
  localStorage.removeItem('email')
  localStorage.removeItem('username')
}

// ------------------------------------
// Reducer
// ------------------------------------
const initialState = {
  isLoggedIn: false,
  loginError: null,
  userInfo: {
    hashtags: []
  }
}

export default createReducer({
  [clearError]: (state, payload) => ({
    ...state,
    [payload]: null
  }),
  [loginSuccess]: (state, payload) => ({
    ...state,
    isLoggedIn: true,
    loginError: null,
    userInfo: {
      ...state.userInfo,
      ...payload
    },
    authToken: payload.authentication_token
  }),
  [loginFail]: (state, payload) => ({
    ...state,
    isLoggedIn: false,
    loginError: payload.response.data.error,
    userInfo: {}
  }),
  [logoutSuccess]: (state) => ({
    ...state,
    isLoggedIn: false,
    userInfo: {},
    authToken: null,
    loginError: null
  }),
  [startUserSession]: (state, payload) => ({
    ...state,
    isLoggedIn: true,
    authToken: payload.token,
    email: payload.email,
    username: payload.username
  }),
  [updateUser]: (state, payload) => ({
    ...state,
    userInfo: {
      ...state.userInfo,
      ...payload
    }
  })
}, initialState)
