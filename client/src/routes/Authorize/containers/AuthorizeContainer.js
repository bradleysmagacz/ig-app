import { connect } from 'react-redux'
import { authorizeInstagramUser } from 'store/sessionReducer'

import Authorize from '../components/Authorize'

const mapDispatchToProps = {
  authorizeInstagramUser
}

const mapStateToProps = (state) => ({
  isLoggedIn: state.session.isLoggedIn
})

export default connect(mapStateToProps, mapDispatchToProps)(Authorize)
