module Scrapers
  def self.all
    syms = self.constants.select do |c|
      self.const_get(c).is_a? Class
    end

    syms.map { |c| Object::const_get("Scrapers::#{c}").new }.select do |s|
      s.active?
    end
  end

  class RepBenchScraper < Scraper
    def initialize
      super("https://www.repfitness.com/strength-equipment/strength-training/benches")
    end

    def active?
      false
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

  class PtCoffeeScraper < Scraper
    def initialize
      super("https://www.ptscoffee.com/collections/single-origin-coffee/products/yirgacheffe-tigesit-waqa-natural")
    end

    def process_page(html)
      status = html.css("#AddToCartText-product-template").inner_html&.strip
      "Tigesit Waqa Natural is #{status}"
    end
  end

  class ArmillaScraper < Scraper
    def initialize
      super("https://armillawatchbands.com/collections/aero-ballistic/products/aero-ballistic-baby-blue-g10-nato?variant=17646199111738")
    end

    def active?
      false
    end

    def process_page(html)
      status = html.css(".btn--to-secondary > span:nth-child(1)").inner_html&.strip
      "Strap is #{status}"
    end
  end

  class ViknChalk < Scraper
    def initialize
      super("https://viknperformance.com/collections/liquid-chalk-vikn-performance/products/liquid-chalk")
    end

    def process_page(html)
      button = html.css("#AddToCart-1515994021941 span")
      "Liquid chalk is #{button&.inner_html&.strip}"
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
end
