import { connect } from 'react-redux'
import { clearError, register } from 'store/sessionReducer'

import Register from '../components/Register'

const mapDispatchToProps = {
  clearError,
  register
}

const mapStateToProps = (state) => ({
  isLoggedIn: state.session.isLoggedIn
})

export default connect(mapStateToProps, mapDispatchToProps)(Register)
