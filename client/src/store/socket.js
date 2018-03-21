export default class ActionCableClient {
  constructor (uri, channel, onMessage, email, token) {
    this.uri = uri
    this.channel = channel
    this.onMessage = onMessage

    this.socket = new WebSocket(`${uri}?email=${email}&token=${token}`)
    this.socket.onmessage = this._handleMessage.bind(this)

    this._onReadyPromise = new Promise((resolve, reject) => {
      this._resolveOnReady = resolve
      this._rejectOnReady = reject
    })
  }

  static connect (uri, channel, onMessage, email, token) {
    const instance = new this(uri, channel, onMessage, email, token)
    return instance.connect()
  }

  connect () {
    this.socket.onopen = () => {
      this.socket.send(this._getSubscribePayload())
    }

    return this._onReadyPromise
  }

  _handleMessage (event) {
    const msg = JSON.parse(event.data)
    if (msg.type === 'confirm_subscription') {
      this._resolveOnReady(this)
    } else {
      this.onMessage(msg)
    }
  }

  _getSubscribePayload () {
    return JSON.stringify({
      command: 'subscribe',
      identifier: JSON.stringify({
        channel: this.channel
      })
    })
  }
}
