import { connect } from 'react-redux'
import { clearError, login } from 'store/sessionReducer'

import Login from '../components/Login'

const mapDispatchToProps = {
  clearError,
  login
}

const mapStateToProps = (state) => ({
  isLoggedIn: state.session.isLoggedIn,
  loginError: state.session.loginError
})

export default connect(mapStateToProps, mapDispatchToProps)(Login)
