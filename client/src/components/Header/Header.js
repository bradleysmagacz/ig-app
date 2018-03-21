import React from 'react'
import PropTypes from 'prop-types'
import { IndexLink, Link } from 'react-router'
import AppBar from 'material-ui/AppBar'
import FlatButton from 'material-ui/FlatButton'
import './Header.scss'

export default class Header extends React.Component {

  static propTypes = {
    isLoggedIn: PropTypes.bool,
    logout: PropTypes.func,
    router: PropTypes.object,
    startUserSession: PropTypes.func

  }

  constructor (props) {
    super(props)
    this.logout = this.logout.bind(this)
  }

  renderLoggedInView () {
    return (
      <div>
        <FlatButton
          containerElement={<Link to='/dashboard' activeClassName='route--active' />}>
          Dashboard
        </FlatButton>
        <FlatButton
          onClick={this.logout}
          style={{ cursor: 'pointer', verticalAlign: 'top' }}>
          Logout
        </FlatButton>
      </div>
    )
  }

  renderLoggedOutView () {
    return (
      <div>
        <FlatButton
          containerElement={<Link to='/login' activeClassName='route--active' />}>
          Login
        </FlatButton>
      </div>
    )
  }

  logout = () => this.props.logout().then(() => this.props.router.push('/'))

  render () {
    const { isLoggedIn } = this.props
    return (
      <div style={{ fontSize: '1.3em' }}>
        <AppBar
          style={{ width: '100%', backgroundColor: 'white' }}
          title={<IndexLink to='/' style={{ color: '#ff5c5c' }}>Porter</IndexLink>}
          showMenuIconButton={false}
          zDepth={2}
          iconElementRight={isLoggedIn ? this.renderLoggedInView() : this.renderLoggedOutView()}
          iconStyleRight={{ marginTop: '14px' }}
        />
      </div>
    )
  }
}
