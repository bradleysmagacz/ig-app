import React from 'react'
import PropTypes from 'prop-types'
import Paper from 'material-ui/Paper'
import TextField from 'material-ui/TextField'
import RaisedButton from 'material-ui/RaisedButton'
import { List, ListItem } from 'material-ui/List'
import Divider from 'material-ui/Divider'
import Toggle from 'material-ui/Toggle'
import FontIcon from 'material-ui/FontIcon'
import { Grid, Row, Col } from 'react-flexbox-grid'
import Clear from 'material-ui/svg-icons/content/clear'
import Edit from 'material-ui/svg-icons/content/create'

export default class HashtagList extends React.Component {

  static propTypes = {
    addHashtagToInstagramLikeList: PropTypes.func,
    hashtags: PropTypes.array.isRequired,
    removeHashtagFromInstagramLikeList: PropTypes.func,
    updateUser: PropTypes.func
  }

  constructor (props) {
    super(props)
    this.state = {
      hashtagValue: '',
      editingTag: '',
      newValue: ''
    }
    this.addHashtag = this.addHashtag.bind(this)
    this.handleChange = this.handleChange.bind(this)
    this.removeHashtag = this.removeHashtag.bind(this)
  }

  addHashtag (e, value) {
    e.preventDefault()
    const { hashtags } = this.props
    const { hashtagValue } = this.state
    const hashtagExists = hashtags.some(tag => tag.name === value)
    if (!hashtagExists) {
      this.props.addHashtagToInstagramLikeList(hashtagValue)
        .then(res => this.props.updateUser(res.data))
        .catch(err => console.log('do something about this error', err))
    }
    this.setState({ editingTag: '', hashtagValue: '', newValue: '' })
  }

  editValue (editingTag) {
    this.setState({ editingTag, newValue: editingTag })
    // this.nameInput.focus()
  }

  handleChange (ev, field) {
    this.setState({ [field]: ev.target.value })
  }

  removeHashtag (hashtagId) {
    this.props.removeHashtagFromInstagramLikeList(hashtagId)
      .then(res => this.props.updateUser(res.data))
      // handle error when it does not get deleted
      .catch(err => err)
  }

  render () {
    const { hashtags } = this.props
    console.log('props in hashtag list', hashtags)
    return (
      <div>
        <Paper zDepth={2} style={{ color: 'black' }}>
          <form onSubmit={(e) => this.addHashtag(e, this.state.hashtagValue)} style={{ marginBottom: '35px' }}>
            <TextField
              name='hashtag'
              floatingLabelText='Hashtag'
              value={this.state.hashtagValue}
              onChange={(e) => this.handleChange(e, 'hashtagValue')}
            />
            <RaisedButton
              onClick={(e) => this.addHashtag(e, this.state.hashtagValue)}
              style={{ marginLeft: '12px' }}
              overlayStyle={{ padding: '0 8px' }}>
              Add Hashtag
            </RaisedButton>
          </form>
          {hashtags && hashtags.length > 0
          ? <Grid fluid>
            <Row style={{ paddingLeft: '10px' }}>
              <Col xs={4} md={4} lg={4} style={{ textAlign: 'left' }}>
                <span>Hashtag</span>
              </Col>
              <Col xs={2} md={2} lg={2}>
                <span>Edit</span>
              </Col>
              <Col xs={2} md={2} lg={2}>
                <span>Remove</span>
              </Col>
              <Col xs={2} md={2} lg={2}>
                <span>Like</span>
              </Col>
              <Col xs={2} md={2} lg={2}>
                <span>Comment</span>
              </Col>
            </Row>
            <Divider />
            <List>
              {hashtags.map((tag, index) => (
                <Row key={tag.name} style={{ padding: '5px 0 5px 10px' }}>
                  <Col xs={4} md={4} lg={4} style={{ textAlign: 'left' }}>
                    {this.state.editingTag === tag.name
                    ? <form onSubmit={(e) => this.addHashtag(e, this.state.newValue)}>
                      <TextField
                        name='hashtag'
                        value={this.state.newValue}
                        onChange={(e) => this.handleChange(e, 'newValue')}
                        underlineShow={false}
                        autoFocus
                        style={{ height: 'auto' }}
                        inputStyle={{ fontSize: '14px' }}
                      />
                    </form>
                    : <span>{tag.name}</span>
                    }
                  </Col>
                  <Col xs={2} md={2} lg={2}>
                    <Edit
                      color='darkgray'
                      hoverColor='black'
                      style={{ cursor: 'pointer', display: 'inline-block', width: '20px', height: '20px' }}
                      onClick={() => this.editValue(tag.name)}
                    />
                  </Col>
                  <Col xs={2} md={2} lg={2}>
                    <Clear
                      color='darkgray'
                      hoverColor='black'
                      onClick={() => this.removeHashtag(tag.id)}
                      style={{ cursor: 'pointer', display: 'inline-block', width: '20px', height: '20px' }}
                    />
                  </Col>
                  <Col xs={2} md={2} lg={2}>
                    <Toggle style={{ width: 'auto', margin: '0 auto' }} />
                  </Col>
                  <Col xs={2} md={2} lg={2}>
                    <Toggle style={{ width: 'auto', margin: '0 auto' }} />
                  </Col>
                </Row>
              ))}
            </List>
          </Grid>
          : <div style={{ paddingBottom: '25px' }}>You have no hashtags. Add one above!</div>
          }
        </Paper>
      </div>
    )
  }
}
