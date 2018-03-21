import { injectReducer } from 'store/reducers'

const requireAuth = (nextState, replace, callback) => {
  const token = localStorage.getItem('authToken')
  if (!token) replace('/login')
  return callback()
}

export default (store) => ({
  onEnter: requireAuth,
  path: 'dashboard',
  getComponent (nextState, cb) {
    require.ensure([], (require) => {
      const Dashboard = require('./containers/DashboardContainer').default
      const reducer = require('./modules/dashboard').default

      injectReducer(store, { key: 'dashboard', reducer })

      cb(null, Dashboard)
    }, 'dashboard')
  }
})
