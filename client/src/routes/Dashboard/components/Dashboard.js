import React from 'react'
import PropTypes from 'prop-types'
import ActionCableClient from 'store/socket'
import { Grid, Row, Col } from 'react-flexbox-grid'

// Material UI
import Paper from 'material-ui/Paper'
import TextField from 'material-ui/TextField'
import RaisedButton from 'material-ui/RaisedButton'

// Components
import HashtagList from './HashtagList'
import UserStats from './UserStats'

export default class Dashboard extends React.Component {

  static propTypes = {
    addHashtagToUser: PropTypes.func,
    addHashtagToInstagramLikeList: PropTypes.func,
    authToken: PropTypes.string,
    email: PropTypes.string,
    removeHashtagFromUser: PropTypes.func,
    removeHashtagFromInstagramLikeList: PropTypes.func,
    retrieveUserInfoWithStats: PropTypes.func,
    router: PropTypes.object,
    updateUser: PropTypes.func,
    userInfo: PropTypes.object,
    username: PropTypes.string
  }

  constructor (props) {
    super(props)
    this.handleSocketEvents = this.handleSocketEvents.bind(this)
  }

  componentDidMount () {
    const { authToken, email, username } = this.props
    if (authToken) {
      ActionCableClient.connect(
        'ws://localhost:3100/connect',
        'DashboardChannel',
        this.handleSocketEvents,
        username || email,
        authToken
      ).then(client => {
        // do something
      })
      console.log('user', this.props.userInfo)
      if (!this.props.userInfo.stats) this.props.retrieveUserInfoWithStats(this.props.userInfo.email)
    } else {
      this.props.router.push('/login')
    }
  }

  handleSocketEvents (event) {
    if (event.message && event.message.user) {
      console.log('socket event', event.message)
      this.props.updateUser(event.message.user)
    }
  }

  render () {
    if (this.props.userInfo && Object.keys(this.props.userInfo).length > 0) {
      return (
        <div>
          <div>Dashboard!</div>
          {/* <a href='http://localhost:3100/authorize' target='_blank'>Authorize</a> */}
          <Grid fluid>
            <Row>
              <Col xs={12} sm={6} md={6} lg={6} style={{ margin: '5px 0' }} >
                <UserStats stats={this.props.userInfo.stats} />
              </Col>
              <Col xs={12} sm={6} md={6} lg={6} style={{ margin: '5px 0' }}>
                <HashtagList {...this.props} />
              </Col>
              {/* <Col xs={12} sm={6} md={6} lg={4} style={{ margin: '5px 0' }}>
                <Paper zDepth={2} style={{ padding: '50px'}}>Some other widget for demo purposes</Paper>
              </Col> */}
            </Row>
          </Grid>
        </div>
      )
    }
    return <div>Hold on a moment while we retrieve your information...</div>
  }
}
