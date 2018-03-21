import React from 'react'
import PropTypes from 'prop-types'
import './HomeView.scss'

export const HomeView = (props) => {
  // Redirect to dashboard for now
  props.router.push('/dashboard')
  return (
    <div>
      <h4>Welcome!</h4>
    </div>
  )
}

HomeView.propTypes = {
  router: PropTypes.object
}

export default HomeView
