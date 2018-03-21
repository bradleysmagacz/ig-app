import { connect } from 'react-redux'
import {
  addHashtagToInstagramLikeList,
  removeHashtagFromInstagramLikeList,
  retrieveUserInfoWithStats
} from '../modules/dashboard'

import { updateUser } from 'store/sessionReducer'

import Dashboard from '../components/Dashboard'

const mapDispatchToProps = {
  addHashtagToInstagramLikeList,
  removeHashtagFromInstagramLikeList,
  retrieveUserInfoWithStats,
  updateUser
}

const mapStateToProps = (state) => ({
  authToken: state.session.authToken,
  email: state.session.userInfo.email,
  hashtags: state.session.userInfo.hashtags,
  username: state.session.username,
  userInfo: state.session.userInfo
})

export default connect(mapStateToProps, mapDispatchToProps)(Dashboard)
