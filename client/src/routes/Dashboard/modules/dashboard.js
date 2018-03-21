import { createAction, createReducer } from 'redux-act'
import axios from 'axios'
import config from 'config/app-config.json'

// ------------------------------------
// Actions
// ------------------------------------
export const userStatsRetrieved = createAction('USER_STATS_RETRIEVED')

export const addHashtagToInstagramLikeList = (hashtag) =>
  (dispatch, getState) => {
    const { userInfo } = getState().session
    return axios({
      method: 'POST',
      url: `${config.apiBase}/instagram/like`,
      // headers: {
      //   'X-User-Username': userInfo.username,
      //   'X-User-Token': userInfo.authToken
      // },
      headers: {
        'X-User-Email': userInfo.email,
        'X-User-Token': userInfo.authToken
      },
      data: { hashtag }
    })
  }

export const removeHashtagFromInstagramLikeList = (id) =>
  (dispatch, getState) => {
    const { userInfo } = getState().session
    return axios({
      method: 'DELETE',
      url: `${config.apiBase}/instagram/like`,
      headers: {
        'X-User-Username': userInfo.username || userInfo.email,
        'X-User-Token': userInfo.authToken
      },
      data: { hashtag_id: id }
    })
  }

export const retrieveUserInfoWithStats = (userId) =>
  (dispatch, getState) => {
    return axios({
      method: 'GET',
      url: `${config.apiBase}/dashboard`,
      headers: {
        'X-User-Username': 'gerardbutler9803',
        'X-User-Token': getState().session.userInfo.authToken
      }
    })
    .then(res => dispatch(userStatsRetrieved({ hashtags: [], stats: {} })))
    .catch(err => dispatch(userStatsRetrieved({ hashtags: [], stats: {} })))
  }

// ------------------------------------
// Reducer
// ------------------------------------
const initialState = {
  hashtags: [],
  hashtagInfo: {
    auto_comment_on: false,
    auto_follow_on: false,
    auto_like_on: true,
    name: ''
  }
}
export default createReducer({
  [userStatsRetrieved] : (state, payload) => ({
    ...state,
    userInfo: payload,
    hashtags: payload.hashtags
  })
}, initialState)
