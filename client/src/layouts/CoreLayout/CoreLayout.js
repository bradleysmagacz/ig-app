import React from 'react'
import Header from '../../components/Header'
import './CoreLayout.scss'
import '../../styles/core.scss'

export const CoreLayout = ({ children, router }) => (
  <div className='bg' style={{ width: '100vw', height: '100vh' }}>
    <Header router={router} />
    <div className='text-center'>
      <div className='core-layout__viewport'>
        {children}
      </div>
    </div>
  </div>
)

CoreLayout.propTypes = {
  children: React.PropTypes.element.isRequired,
  router: React.PropTypes.object.isRequired
}

export default CoreLayout
