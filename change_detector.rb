require "sqlite3"
require "digest/md5"

class ChangeDetector
  attr_reader :url, :hash

  def initialize(scraper, dbfile = "#{ENV["DBPATH"] || File.dirname(__FILE__)}/scrape.db")
    @db = SQLite3::Database.new(dbfile)
    @db.execute <<-SQL
    create table if not exists scrapes (
        url varchar(1024),
        hash varchar(512),
        constraint scrapes_unq unique (url)
    );
    SQL

    @url = scraper.url
    @hash = Digest::MD5.new << (scraper.message || "error processing page @ #{Time.now}")

    # seed url into the db to make `changed?` queries easier (can issue an udpate, no need for an insert)
    # the `or ignore` will allow this to silently fail if we hit the uniqueness contraint (i.e. it's already been seeded)
    @db.execute("insert or ignore into scrapes (url) values (?)", [@url])
  end

  def changed?
    # update only if null or if different from current hash
    @db.execute("update scrapes set hash=? where url=? and (hash is null or hash<>?)", [hash.to_s, url, hash.to_s])
    
    # return true if we updated the record (i.e. changed it hash, including from null to something)
    @db.changes == 1
  end
end
