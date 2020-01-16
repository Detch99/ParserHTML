require 'curb'
require 'nokogiri'
require 'json'
require 'csv'
require_relative 'product'
require_relative 'product_parser'
require_relative 'logging_utils'

LoggingUtils.log("Initial params")
URL_CATEGORY = ARGV[0]
FILE_OUTPUT = ARGV[1]
products = []
page_number = 2

def get_html (url)
  http = Curl.get(url)
  Nokogiri::HTML(http.body_str)
end

LoggingUtils.log("Parsing category into links")
products_links = ProductParser.parse_categories_into_links(get_html(URL_CATEGORY))

while true do
  category = ProductParser.parse_categories_into_links(get_html(URL_CATEGORY + "/?p=" + page_number.to_s))
  if category == []
    break
  end
  products_links += category
  page_number += 1
end

LoggingUtils.log("Parsing products pages")
products_links.each { |product_link| products += ProductParser.parse_html(get_html(product_link)) }

LoggingUtils.log("Wrie products to csv")
ProductParser.write_products_to_csv(products, FILE_OUTPUT,)
