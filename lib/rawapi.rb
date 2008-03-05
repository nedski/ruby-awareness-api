Dir[File.join(File.dirname(__FILE__), 'rawapi/**/*.rb')].sort.each { |lib| require lib }

require 'open-uri'
require 'rexml/document'
include REXML

# Class to provide the interface to the Awareness API
#
# dates:
#  * Individual dates always use this format: YYYY-MM-DD
#  * Date ranges are expressed with a comma: YYYY-MM-D1, YYYY-MM-D7 means all dates between and including D1 and D7
#  * If a range is specified, the second date must always be later than the first date
#  * A single date will be interpreted as a range of one date: YYYY-MM-D1 = YYYY-MM-D1, YYYY-MM-D1
#  * Discrete ranges are separated by a slash: YYYY-MM-D1/YYYY-MM-D5/YYYY-MM-D7,YYYY-MM-D14 means D1 and D5 and all dates between and including D7 and D14. Multiple discrete ranges may also be provided by using multiple date parameters in a single GET request.
#  * If no date is specified, Yesterday's date is assumed. "Current" is always yesterday's data. "Live" daily data is not yet available.
#  * An individual date starts at 12am CDT (GMT -5) and ends 12am CDT the next day. Custom timezone support is not yet available.
class AwarenessApi
  ROOT_API_URL = 'http://api.feedburner.com/awareness/1.0/'
  
  # Get Basic Feed Awareness Data
  #
  # options:
  #  * uri: The URI of the feed (same as http://feeds.feedburner.com/<feeduri>) Must be used if id is not specified
  #  * id: The FeedBurner id of the feed (visible when editing a feed in your account, e.g., http://www.feedburner.com/fb/a/optimize?id=<id>). May be used instead if uri is not specified.
  #  * dates: Dates are used to specify the period for which data is need (see note on dates above)
  def get_feed_data(options)
    option_string = parse_options(options)
    
    response_xml = open("#{ROOT_API_URL}GetFeedData?#{option_string}").read
    return parse_xml(response_xml)
  end
  
  # Get Individual Item Awareness Data (TotalStats pro)
  #
  # options:
  #  * uri: The URI of the feed (same as http://feeds.feedburner.com/<feeduri>) Must be used if id is not specified
  #  * id: The FeedBurner id of the feed (visible when editing a feed in your account, e.g., http://www.feedburner.com/fb/a/optimize?id=<id>). May be used instead if uri is not specified.
  #  * itemurl: The source URL of item (not the FeedBurner generated URL, but the original source URL). Multiple itemurl parameters may be provided in a single request in order to retrieve additional items.
  #  * dates: Dates are used to specify the period for which data is need (see note on dates above)
  def get_item_data(options)
    option_string = parse_options(options)
    
    response_xml = open("#{ROOT_API_URL}GetItemData?#{option_string}").read
    return parse_xml(response_xml)
  end
  
  # Get Resyndication Feed Awareness Data (TotalStats pro)
  #
  # options:
  #  * uri: The URI of the feed (same as http://feeds.feedburner.com/<feeduri>)
  #  * id: The FeedBurner id of the feed (visible when editing a feed in your account, e.g., http://www.feedburner.com/fb/a/optimize?id=<id>). May be used instead if uri is not specified.
  #  * itemurl: The source URL of item (not the FeedBurner generated URL, but the original source URL). Multiple itemurl parameters may be provided in a single request in order to retrieve additional items.
  #  * dates: Dates are used to specify the period for which data is need (see note on dates above)
  def get_resyndication_data(options)
    option_string = parse_options(options)
    
    response_xml = open("#{ROOT_API_URL}GetResyndicationData?#{option_string}").read
    return parse_xml(response_xml)
  end
  
  private
  def parse_options(options)
    raise "options must include a feed id or uri" unless options[:id] or options[:uri]
    
    options[:uri] = nil if options[:id] and options[:uri]
    
    return options.collect {|key, value| "#{key}=#{value}" unless value.nil?}.compact.join('&')
  end
  
  def parse_xml(response_xml)
    response = Response.new
    
    xml = Document.new(response_xml)
    rsp_node = xml.root
    
    response.status = rsp_node.attributes['stat']
    
    if response.status == 'fail'
      response.code = rsp_node.elements[1].attributes['code']
      response.message = rsp_node.elements[1].attributes['msg']
    elsif response.status == 'ok'
      for feed_node in rsp_node.elements
        feed = Feed.new
        
        feed.id = feed_node.attributes['id']
        feed.uri = feed_node.attributes['uri']
        
        response.feeds << feed
        
        for entry_node in feed_node.elements
          entry = Entry.new
          
          entry.date = entry_node.attributes['date']
          entry.circulation = entry_node.attributes['circulation']
          entry.hits = entry_node.attributes['hits']
          
          feed.entries << entry
          
          for item_node in entry_node.elements
            item = Item.new
            
            item.title = item_node.attributes['title']
            item.url = item_node.attributes['url']
            item.itemviews = item_node.attributes['itemviews']
            item.clickthroughs = item_node.attributes['clickthroughs']
            
            entry.items << item
            
            for referer_node in item_node.elements
              referer = Referer.new
              
              referer.url = referer_node.attributes['url']
              referer.itemviews = referer_node.attributes['itemviews']
              referer.clickthroughs = referer_node.attributes['clickthroughs']
              
              item.referers << referer
            end
          end
        end
      end
    end
    
    return response
  end
end

# rawapi = AwarenessApi.new
# opts = {:uri => 'CommonThread', :dates => '2007-03-20,2007-03-23'}
# 
# puts rawapi.get_feed_data(opts)
# puts rawapi.get_item_data(opts)
# puts rawapi.get_resyndication_data(opts)