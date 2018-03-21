require 'openssl'
require 'base64'

def generate_sig(endpoint, params, secret)
  sig = endpoint
  params.sort.map do |key, val|
    sig += '|%s=%s' % [key, val]
  end
  digest = OpenSSL::Digest.new('sha256')
  return OpenSSL::HMAC.hexdigest(digest, secret, sig)
end
