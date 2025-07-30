require 'rack/request'
require 'digest/sha1'
require 'connection_pool'
require_relative 'db/database'

run do |env|
  Database.with_connection_pool do |db_conn|
    req = Rack::Request.new(env)
    request_method = req.request_method

    case request_method
    when 'GET'
      handle_get(req, db_conn:)
    when 'POST'
      handle_post(req, db_conn:)
    when 'HEAD'
      [200, { 'content-type' => 'text/plain' }, []]
    else
      [404, { 'content-type' => 'text/plain' }, ['Not Found']]
    end
  end
end

def handle_post(req, db_conn:)
  content_type = req.content_type
  if content_type == 'text/plain'
    url = req.body.read
    encoded = Digest::SHA1.hexdigest(url)

    begin
      db_conn.insert_link(encoded, url)
      [201, { 'content-type' => 'text/plain' }, [encoded]]
    rescue SQLite3::ConstraintException
      [409, { 'content-type' => 'text/plain' }, ['URL already shortened']]
    rescue SQLite3::Exception => e
      [500, { 'content-type' => 'text/plain' }, ["Database error: #{e.message}"]]
    end
  else
    [422, { 'content-type' => 'text/plain' }, ['Content Type must be "text/plain"']]
  end
end

def handle_get(req, db_conn:)
  path = req.path[1..]
  link = db_conn.get_link(path)

  if link
    [301, { 'content-type' => 'text/plain', 'location' => link }, ["Moved Permanently. Redirecting to #{link}"]]
  else
    [404, { 'content-type' => 'text/plain' }, ['Not found.']]
  end
end
