require 'sqlite3'

SQLite3::Database.new('links.db').tap do |db|
  db.results_as_hash = true
  db.execute <<-SQL
    DROP TABLE IF EXISTS links;
  SQL
  db.execute <<-SQL
    CREATE TABLE IF NOT EXISTS links (
      id INTEGER PRIMARY KEY,
      key TEXT UNIQUE,
      url TEXT NOT NULL
    );
  SQL
  puts 'Fresh database created!'
end
