require "json"
require "faraday"
require "nokogiri"

require_relative "scraper"
require_relative "change_detector"


raise "missing SLACK_HOOK" if ENV["SLACK_HOOK"].nil?


def log(msg)
  puts "#{Time.now} * #{msg}"
end


class RlScraper < Scraper
  def initialize
    super("https://www2.rlcarriers.com/freight/shipping/shipment-tracing?docType=PRO&source=web&pro=XXXYYYYZZZ")
  end

  def process_page(contents)
    html = Nokogiri::HTML(contents)
    t = html.css("#XXXYYYYZZZ-div > table:nth-child(3)")
    t.xpath("//td").map(&:text).join(" ").gsub(/XXXYYYYZZZ.*MM\/DD\/YYYY/, "\nest deliv: ")
  end
end


class RepScraper < Scraper
  def initialize
    super("https://www.repfitness.com/strength-equipment/strength-training/benches")
  end

  def process_page(contents)
    products = []

    # all this nokogiri css business is to allow for a message specific to the in-stock items
    # none of it's necessary if you just want to know whether or not a page has changed
    # note, though, all this really only works for static html pages
    html = Nokogiri::HTML(contents)
      
    html.css("ol.products").each do |product|
      product.css("div.product-item-info").each do |item|
        if item.css("div.actions-primary").to_s.include?("tocart-form")
          products << item.css("a.product-item-link").inner_html.strip!
        end 
      end
    end
  
    if products.any? { |sku| sku.include? "FB-" }
      "items in stock at #{url}\n#{products.sort.join("\n")}"
    else
      "no products of interest"
    end
  end
end

scrapers = [
  RlScraper.new,
  RepScraper.new,
]

scrapers.each do |scraper|
  cd = ChangeDetector.new(scraper)

  if cd.changed?
    log "posting change to slack"
    Faraday.post(ENV["SLACK_HOOK"], {text: "changes at #{scraper.url}\n#{scraper.slack_message_body}"}.to_json.to_s)
  else
    log "no changes detected"
  end
end

log "goodbye"
