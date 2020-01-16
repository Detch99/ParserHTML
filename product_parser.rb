require_relative 'product'
require_relative 'logging_utils'

class ProductParser

  NAME_XPATH = "//*[@class='nombre_fabricante_bloque col-md-9 desktop']"
  PRICES_XPATH = "//*[@class='price_comb']"
  WEIGHTS_XPATH = "//*[@class='radio_label']"
  IMAGES_LINKS_XPATH = "//*[@id='thumbs_list_frame']/li/a"
  PRODUCTS_LINKS_XPATH = "//*[@id='product_list']/li/div/div/div/a"

  def self.parse_html(document)

    name = document.xpath(NAME_XPATH)
               .map{|name| name.text}[0] # take the first element since the product name is the only one for all weights
    prices = document.xpath(PRICES_XPATH)
                 .map{|price| price.text}
    weights = document.xpath(WEIGHTS_XPATH)
                  .map{|weight| weight.text}
    images_links = document.xpath(IMAGES_LINKS_XPATH)
                       .map{|html_link| html_link[:href]}
    generate_products_list(name, weights, prices, images_links)
  end

  def self.write_products_to_csv(products, file_name, file_opening_mode="wb")
    CSV.open(
        file_name,
        file_opening_mode,
        :write_headers => true,
        :headers => %w(name price image),
        ) do |csv|
      products.each do |product|
        csv << [product.name, product.price, product.img]
      end
    end
  end

  def self.generate_products_list(product_name, weights, prices, images_links)
    LoggingUtils.log("------------")
    products = []
    weights.each_index do |index|
      weight = weights[index]
      price = prices[index]

      image_link = images_links[index]
      unless image_link
        # The only possible case here is when number of weights is larger than number of images.
        # In this case we assuming that the first image is applying for all weights
        image_link = images_links[0]
      end

      product = Product.new(product_name + " - " + weight, price, image_link)
      products.push(product)
    end
    LoggingUtils.log("-===============-")
    products
  end

  def self.parse_categories_into_links (document)
    products_links = document.xpath(PRODUCTS_LINKS_XPATH)
                 .map{|price| price[:href]}.reject(&:empty?)
    products_links
  end

end