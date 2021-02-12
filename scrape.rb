require "nokogiri"
require "open-uri"
require "faraday"
require "json"
require "sqlite3"
require "digest/md5"

raise "missing SLACK_HOOK" if ENV["SLACK_HOOK"].nil?

class ChangeDetector
  DBFILE = "#{ENV["DBPATH"] || File.dirname(__FILE__)}/scrape.db"
  attr_reader :url, :hash

  def initialize(url, contents)
    @db = SQLite3::Database.new(DBFILE)
    @db.execute <<-SQL
      create table if not exists scrapes (
        url varchar(1024),
        hash varchar(512),
        constraint scrapes_unq unique (url)
      );
    SQL

    @url = url
    @hash = Digest::MD5.new << contents

    seed
  end

  def seed
    @db.execute("insert or ignore into scrapes(url) values (?)", [@url])
  end

  def changed?
    @db.execute("update scrapes set hash=? where url=? and (hash is null or hash<>?)", [hash.to_s, url, hash.to_s])
    @db.changes == 1
  end
end

def log(msg)
  puts "#{Time.now} * #{msg}"
end

class Scraper
  attr_reader :url, :message

  def initialize
    @products = []
    @url = "https://www.repfitness.com/strength-equipment/strength-training/benches"
  end

  def message
    @message ||= fetch
  end

  def fetch
    URI.open(@url) do |f|
      log "fetching page"
      html = Nokogiri::HTML(f.read)
      
      log "processing results"
      html.css("ol.products").each do |product|
        product.css("div.product-item-info").each do |item|
          if item.css("div.actions-primary").to_s.include?("tocart-form")
            @products << item.css("a.product-item-link").inner_html.strip!
          end 
        end
      end
    end
  
    if @products.any? { |sku| sku.include? "FB-" }
      "items in stock at #{url}:\n#{@products.sort.join("\n")}"
    else
      "no products of interest"
    end
  end
end

scraper = Scraper.new
cd = ChangeDetector.new(scraper.url, scraper.message)

if cd.changed?
  log "posting change to slack"
  Faraday.post(ENV["SLACK_HOOK"], {text: scraper.message}.to_json.to_s)
else
  log "no changes detected"
end
