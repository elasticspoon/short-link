require 'rack/request'
require 'digest/sha1'
KEYS = {}

run do |env|
  req = Rack::Request.new(env)
  request_method = req.request_method

  if request_method == 'GET'
    handle_get(req)
  elsif request_method == 'POST'
    handle_post(req)
  elsif request_method == 'HEAD'
    [200, { 'content-type' => 'text/plain' }, []]
  else
    [404, { 'content-type' => 'text/plain' }, ['Not Found']]
  end
end

def handle_post(req)
  content_type = req.content_type
  if content_type == 'text/plain'
    url = req.body.read
    encoded = Digest::SHA1.hexdigest(url)
    KEYS[encoded] = url
    [201, { 'content-type' => 'text/plain' }, [encoded]]
  else
    [422, { 'content-type' => 'text/plain' }, ['Content Type must be "text/plain"']]
  end
end

def handle_get(req)
  path = req.path[1..]
  real_path = KEYS[path]

  if real_path
    [200, { 'content-type' => 'text/plain' }, ["Redirected to #{real_path}"]]
  else
    [404, { 'content-type' => 'text/plain' }, ['Not found']]
  end
end
