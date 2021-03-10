require "open-uri"
require "nokogiri"

class Scraper
  attr_reader :url, :contents

  def initialize(url)
    @url = url
  end

  def process_page(html)
    raise "implement me"
  end

  def active?
    true
  end

  def message
    @contents ||= begin
      processed = process_page(Nokogiri::HTML(fetch))
      log "processed page"
      processed
    end
  end

private

  def log(message)
    puts "#{Time.now} * #{message}"
  end

  def fetch
    log "fetching page"

    URI.open(url) do |f|
      f.read
    end
  end
end
