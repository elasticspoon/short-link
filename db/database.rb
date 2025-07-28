require 'sqlite3'

module Database
  def self.connect
    SQLite3::Database.new('links.db').tap do |db|
      db.results_as_hash = true
      db.execute <<-SQL
        CREATE TABLE IF NOT EXISTS links (
          id INTEGER PRIMARY KEY,
          key TEXT UNIQUE,
          url TEXT NOT NULL
        )
      SQL
    end
  end
end
