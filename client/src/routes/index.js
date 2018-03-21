import CoreLayout from '../layouts/CoreLayout'
import Home from './Home'
import AuthorizeRoute from './Authorize'
import DashboardRoute from './Dashboard'
import LoginRoute from './Login'
import RegisterRoute from './Register'

export const createRoutes = (store) => ({
  path        : '/',
  component   : CoreLayout,
  indexRoute  : Home,
  childRoutes : [
    AuthorizeRoute(store),
    DashboardRoute(store),
    LoginRoute(store),
    RegisterRoute(store)
  ]
})

export default createRoutes
