require 'digest/sha2'
KEYS = {}

run do |env|
  req = env['protocol.http.request']

  if req.method == 'GET'
    handle_get(req)
  elsif req.method == 'POST'
    handle_post(req, env['CONTENT_TYPE'])
  else
    [404, { 'Content-Type' => 'text/plain' }, ['Not Found']]
  end
end

def handle_post(req, content_type)
  if content_type == 'text/plain'
    url = req.body.read
    encoded = Digest::SHA1.hexdigest(url)
    KEYS[encoded] = url
    [201, { 'Content-Type' => 'text/plain' }, [encoded]]
  else
    [422, { 'Content-Type' => 'text/plain' }, ['Content Type must be "text/plain"']]
  end
end

def handle_get(req)
  path = req.path[1..]
  real_path = KEYS[path]
  sleep 10

  if real_path
    [200, { 'Content-Type' => 'text/plain' }, ["Redirected to #{path}"]]
  else
    [404, { 'Content-Type' => 'text/plain' }, ['Not found']]
  end
end
