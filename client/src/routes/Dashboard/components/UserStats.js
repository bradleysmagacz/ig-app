import React from 'react'
import PropTypes from 'prop-types'
import Paper from 'material-ui/Paper'

const UserStats = ({ stats }) => (
  <div>
    <Paper zDepth={2} style={{ color: 'black', padding: '10px 0' }}>
      <div>Photos posted today: {stats.num_media.today}</div>
      <div>People you've followed today: {stats.num_follows.today}</div>
      <div>People who have followed you today: {stats.num_followed_by.today}</div>
      <div>Likes you've received today: {stats.num_likes_received.today}</div>
      <div>Photos you've liked today: {stats.num_likes_sent.today}</div>
      <div>Comments you've received today: {stats.num_comments_received.today}</div>
      <div>Comment you've made today: {stats.num_comments_sent.today}</div>
    </Paper>
  </div>
)

UserStats.propTypes = {
  stats: PropTypes.object.isRequired
}

export default UserStats
