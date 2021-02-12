require "nokogiri"
require "open-uri"
require "faraday"
require "json"
require "sqlite3"
require "digest/md5"

raise "missing SLACK_HOOK" if ENV["SLACK_HOOK"].nil?

class ChangeDetector
  DBFILE = "#{Dir.pwd}/scrape.db"
  attr_reader :url, :hash

  def initialize(url, contents)
    @db = SQLite3::Database.new(DBFILE)
    @db.execute <<-SQL
      create table if not exists scrapes (
        url varchar(1024),
        hash varchar(512),
        constraint scrapes_unq unique (url, hash)
      );
    SQL

    @url = url
    @hash = Digest::MD5.new << contents
  end

  def changed?
    begin
      @db.execute("delete from scrapes where url=? and hash<>?", [url, hash.to_s])
      @db.execute("insert into scrapes(url, hash) values (?, ?)", [url, hash.to_s])
      return true
    rescue SQLite3::ConstraintException
      return false
    end
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
      "items in stock at #{url}\n#{@products.sort.join("\n")}"
    else
      "no products of interest"
    end
  end
end

scraper = Scraper.new

if ChangeDetector.new(scraper.url, scraper.message).changed?
  log "posting change to slack"

  Faraday.post(ENV["SLACK_HOOK"], {text: scraper.message}.to_json.to_s)
else
  log "no changes detected"
end
