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

  def message
    @contents ||= begin
      processed = process_page(Nokogiri::HTML(fetch))
      puts "#{Time.now} * processed page"
      processed
    end
  end

private

  def fetch
    puts "#{Time.now} * fetching page"

    URI.open(url) do |f|
      f.read
    end
  end
end
