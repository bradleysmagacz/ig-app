import React from 'react'
import PropTypes from 'prop-types'
import { Field, reduxForm } from 'redux-form'
import { TextField } from 'redux-form-material-ui'
import Paper from 'material-ui/Paper'
import RaisedButton from 'material-ui/RaisedButton'

import { email, minLength2, minLength6 } from 'store/validations'

class RegisterView extends React.Component {

  static propTypes = {
    clearError: PropTypes.func,
    error: PropTypes.string,
    handleSubmit: PropTypes.func,
    register: PropTypes.func.isRequired,
    registerError: PropTypes.string,
    logout: PropTypes.func,
    pristine: PropTypes.bool,
    router: PropTypes.object,
    submitting: PropTypes.bool
  }

  constructor (props) {
    super(props)
    this.onSubmit = this.onSubmit.bind(this)
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.pristine && this.props.registerError !== null) {
      this.props.clearError('registerError')
    }
  }

  onSubmit (values) {
    this.props.register(values)
      .then(() => this.props.router.push('/dashboard'))
      .catch(err => err)
  }

  render () {
    const { error, handleSubmit, registerError, submitting } = this.props
    return (
      <Paper
        style={{
          position: 'absolute',
          top: '50%',
          left: '50%',
          padding: '35px 30px',
          transform: 'translate(-50%, -50%)',
          background: 'rgb(250, 250, 250)'
        }}
        zDepth={4}
      >
        <div style={{ fontSize: '26px' }}> Join Us :) </div>
        <form onSubmit={handleSubmit(this.onSubmit)}>
          <div style={{ margin: '10px 0' }}>
            <Field
              name='username'
              type='text'
              component={TextField}
              floatingLabelText='Username'
              floatingLabelFocusStyle={{ color: '#ff5c5c' }}
              underlineFocusStyle={{ borderColor: '#ff5c5c' }}
              errorStyle={{ fontStyle: 'italic' }}
              validate={[ minLength2 ]}
            />
          </div>
          <div style={{ margin: '10px 0' }}>
            <Field
              name='email'
              type='text'
              component={TextField}
              floatingLabelText='Email'
              floatingLabelFocusStyle={{ color: '#ff5c5c' }}
              underlineFocusStyle={{ borderColor: '#ff5c5c' }}
              errorStyle={{ fontStyle: 'italic' }}
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
              validate={[ minLength6 ]}
            />
          </div>
          <div style={{ margin: '10px 0' }}>
            <Field
              name='confirm_password'
              type='password'
              component={TextField}
              floatingLabelText='Confirm Password'
              floatingLabelFocusStyle={{ color: '#ff5c5c' }}
              underlineFocusStyle={{ borderColor: '#ff5c5c' }}
              validate={[ minLength6 ]}
            />
          </div>
          {(error || registerError) &&
            <strong style={{ color: 'red', position: 'absolute', left: '80px' }}>{error || registerError}</strong>
          }
          <div style={{ paddingTop: '45px' }}>
            <RaisedButton type='submit' disabled={submitting}>Sign Up</RaisedButton>
          </div>
        </form>
      </Paper>
    )
  }
}

export default reduxForm({
  form: 'registerForm'  // a unique identifier for this form
})(RegisterView)
