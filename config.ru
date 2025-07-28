require 'rack/request'
require 'digest/sha1'
require 'sqlite3'

# Initialize database
DB = SQLite3::Database.new('links.db')
DB.results_as_hash = true

# Create table if it doesn't exist
DB.execute <<-SQL
  CREATE TABLE IF NOT EXISTS links (
    id INTEGER PRIMARY KEY,
    key TEXT UNIQUE,
    url TEXT NOT NULL
  )
SQL

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

    begin
      DB.execute('INSERT INTO links (key, url) VALUES (?, ?)', [encoded, url])
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

def handle_get(req)
  path = req.path[1..]
  row = DB.get_first_row('SELECT url FROM links WHERE key = ?', [path])

  if row && row['url']
    [200, { 'content-type' => 'text/plain' }, ["Redirected to #{row['url']}"]]
  else
    [404, { 'content-type' => 'text/plain' }, ['Not found']]
  end
end
