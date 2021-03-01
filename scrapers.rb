class Scrapers
  def self.all
    [
      #RepBenchScraper.new,
      RepCannonballScraper.new,
    ]
  end
end

class RepBenchScraper < Scraper
  def initialize
    super("https://www.repfitness.com/strength-equipment/strength-training/benches")
  end

  def process_page(html)
    products = []
      
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

class RepCannonballScraper < Scraper
  def initialize
    super("https://www.repfitness.com/3-cannonball-grips-2566")
  end

  def process_page(html)
    status = html.css(".stock > span:nth-child(1)").inner_html
    "Cannonballs are #{status}"
  end
end
