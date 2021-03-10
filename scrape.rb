require "json"
require "faraday"

require_relative "scraper"
require_relative "scrapers"
require_relative "change_detector"

def log(msg)
  puts "#{Time.now} * #{msg}"
end

if ARGV.include? "--list"
  Scrapers.all.each do |s|
    puts "#{s.class.name} - #{s.url}"
  end
  exit 0
end

raise "missing SLACK_HOOK" if ENV["SLACK_HOOK"].nil?
no_slack = ARGV.include? "--no-slack"

Scrapers.all.each do |scraper|
  cd = ChangeDetector.new(scraper)

  if cd.changed?
    message = "Something changed at #{scraper.url}\n#{scraper.message}"

    log_message = if $DEBUG
      "posting slack: #{message}"
    else
      "posting change to slack"
    end

    log log_message
    Faraday.post(ENV["SLACK_HOOK"], {text: message}.to_json.to_s) unless no_slack
  else
    log "no changes detected"
  end
end

log "goodbye"
