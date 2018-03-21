import React from 'react'
import PropTypes from 'prop-types'

export default class Authorize extends React.Component {

  static propTypes = {
    authorizeInstagramUser: PropTypes.func,
    location: PropTypes.object,
    router: PropTypes.object
  }

  componentWillMount () {
    console.log('what are my props in auth', this.props)
    const { code } = this.props.location.query
    this.props.authorizeInstagramUser(code).then(() => this.props.router.push('/dashboard'))
  }

  render () {
    return null
  }
}
