export default (store) => ({
  path: 'callback',
  getComponent (nextState, cb) {
    require.ensure([], (require) => {
      const Authorize = require('./containers/AuthorizeContainer').default

      cb(null, Authorize)
    }, 'authorize')
  }
})
