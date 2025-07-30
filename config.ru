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

    begin
      encoded = insert_key(url, db_conn)
      [201, { 'content-type' => 'text/plain' }, [encoded]]
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

def insert_key(url, conn, short_url: nil)
  short_url ||= Digest::SHA1.hexdigest(url)[...6]

  begin
    conn.insert_link(short_url, url)
  rescue SQLite3::ConstraintException
    short_url = Digest::SHA1.hexdigest(short_url)[...6]

    return insert_key(url, conn, short_url:)
  end

  short_url
end
