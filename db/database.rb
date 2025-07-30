require 'sqlite3'

class Database
  def self.with_connection_pool
    connection_pool = ConnectionPool.new(size: 5, timeout: 5) do
      connection_pool = SQLite3::Database.new('links.db').tap do |db|
        db.results_as_hash = true
        db.busy_timeout = 5000
      end
    end

    connection_pool.with do |conn|
      yield new(conn)
    end
  end

  def initialize(connection)
    @connection = connection
  end

  attr_reader :connection

  def insert_link(key, url)
    connection.execute('INSERT INTO links (key, url) VALUES (?, ?)', [key, url])
  end

  def get_link(key)
    link = connection.execute('SELECT url FROM links WHERE key = ?', [key])

    link.dig(0, 'url')
  end
end
