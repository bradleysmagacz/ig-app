export default (store) => ({
  path : 'register',
  getComponent (nextState, cb) {
    require.ensure([], (require) => {
      const Register = require('./containers/RegisterContainer').default

      cb(null, Register)
    }, 'register')
  }
})
