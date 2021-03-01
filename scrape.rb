require "json"
require "faraday"

require_relative "scraper"
require_relative "scrapers"
require_relative "change_detector"

raise "missing SLACK_HOOK" if ENV["SLACK_HOOK"].nil?
no_slack = ARGV.include? "--no-slack"

def log(msg)
  puts "#{Time.now} * #{msg}"
end

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
