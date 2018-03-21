import React from 'react'
import PropTypes from 'prop-types'
import { Link } from 'react-router'
import { Field, reduxForm } from 'redux-form'
import { TextField } from 'redux-form-material-ui'
import Paper from 'material-ui/Paper'
import RaisedButton from 'material-ui/RaisedButton'

import { email } from 'store/validations'

class LoginView extends React.Component {

  static propTypes = {
    clearError: PropTypes.func,
    error: PropTypes.string,
    handleSubmit: PropTypes.func,
    login: PropTypes.func.isRequired,
    loginError: PropTypes.string,
    logout: PropTypes.func,
    pristine: PropTypes.bool,
    reset: PropTypes.func,
    router: PropTypes.object,
    submitting: PropTypes.bool
  }

  constructor (props) {
    super(props)
    this.handleSubmit = this.handleSubmit.bind(this)
  }

  componentWillMount () {
    this.props.reset()
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.pristine && this.props.loginError !== null) {
      this.props.clearError('loginError')
    }
  }

  connectToInstagram () {
    window.open('http://localhost:3100/oauth/authorize')
  }

  handleSubmit (values) {
    this.props.login(values)
      .then(() => this.props.router.push('/dashboard'))
      .catch(err => err)
  }

  render () {
    const { error, handleSubmit, loginError, submitting } = this.props
    return (
      <Paper
        style={{
          position: 'absolute',
          top: '50%',
          left: '50%',
          padding: '20px 30px',
          transform: 'translate(-50%, -50%)',
          background: 'rgb(250, 250, 250)'
        }}
        zDepth={4}
      >
        {/* <RaisedButton
          style={{ padding: '5px 20px', marginBottom: '40px' }}
          onClick={this.connectToInstagram}>
          Connect with Instagram
        </RaisedButton>
        <div> OR </div> */}
        <div style={{ fontSize: '26px' }}> Hello! </div>
        <form onSubmit={handleSubmit(this.handleSubmit)}>
          <div style={{ margin: '10px 0' }}>
            <Field
              name='email'
              type='text'
              component={TextField}
              floatingLabelText='Email'
              floatingLabelFocusStyle={{ color: '#ff5c5c' }}
              underlineFocusStyle={{ borderColor: '#ff5c5c' }}
              errorStyle={{ fontStyle: 'italic', position: 'absolute', transform: 'translate(50%, 250%)' }}
              validate={[ email ]}
            />
          </div>
          <div style={{ margin: '10px 0' }}>
            <Field
              name='password'
              type='password'
              component={TextField}
              floatingLabelText='Password'
              floatingLabelFocusStyle={{ color: '#ff5c5c' }}
              underlineFocusStyle={{ borderColor: '#ff5c5c' }}
            />
          </div>
          {(error || loginError) &&
            <strong
              style={{ color: 'red', fontStyle: 'italic', position: 'absolute', transform: 'translateX(-50%)' }}>
              {error || loginError}
            </strong>
          }
          <div style={{ paddingTop: '35px' }}>
            <RaisedButton type='submit' disabled={submitting}>Log In</RaisedButton>
          </div>
          <div style={{ paddingTop: '30px' }}>
            New Here? <Link to={'/register'}>Join Us</Link>
          </div>
        </form>
      </Paper>
    )
  }
}

export default reduxForm({
  form: 'loginForm'  // a unique identifier for this form
})(LoginView)
