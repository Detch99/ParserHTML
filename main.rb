require 'curb'
require 'nokogiri'
require 'csv'
require_relative 'product'
require_relative 'product_parser'
require_relative 'logging_utils'

URL_CATEGORY = ARGV[0]
FILE_OUTPUT = ARGV[1]
page_number = 2

def get_html (url, attempts=3)
  if attempts >= 0
    begin
      http = Curl.get(url)
      Nokogiri::HTML(http.body_str)
    rescue
      LoggingUtils.log("Network error while fetching data from #{url}. Will try again. #{attempts.to_s} attempts left")
      get_html(url, attempts - 1)
    end
  end
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

threads = []
products = []
mutex = Mutex.new

products_links.each do |product_link|
  threads << Thread.new do
    html = get_html(product_link)
    if html
      LoggingUtils.log("Downloaded HTML from #{product_link}. Started parsing products")
      mutex.synchronize do
        products += ProductParser.parse_html(html)
      end
    end
  end
end

threads.map(&:join)

LoggingUtils.log("Finished parsing products. Writing products to #{FILE_OUTPUT}")

ProductParser.write_products_to_csv(products, FILE_OUTPUT,)
