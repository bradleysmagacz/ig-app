import { connect } from 'react-redux'
import { logout, startUserSession } from 'store/sessionReducer'
import Header from './Header'

const mapDispatchToProps = {
  logout,
  startUserSession
}

const mapStateToProps = (state) => ({
  isLoggedIn: state.session.isLoggedIn
})

export default connect(mapStateToProps, mapDispatchToProps)(Header)
