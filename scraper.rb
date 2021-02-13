require "open-uri"

class Scraper
  attr_reader :url, :contents

  def initialize(url)
    @url = url
  end

  # this is what gets slacked
  def slack_message_body
    contents
  end

  # contents will determine if the site changed
  # this will be a message containing the list of in-stock items
  def contents
    @contents ||= fetch
  end

  def fetch
    log "fetching page"

    resp = URI.open(url) do |f|
      process_page(f.read)
    end

    log "processed page"

    resp
  end

  def process_page(contents)
    raise "implement me"
  end

  def log(msg)
    puts "#{Time.now} * #{msg}"
  end
end
