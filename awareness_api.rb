require 'open-uri'
require 'rexml/document'
include REXML

class AwarenessApi
  def get_feed_data(options)
    option_string = parse_options(options)
    
    response_xml = open("http://api.feedburner.com/awareness/1.0/GetFeedData?#{option_string}").read
    return parse_xml(response_xml)
  end
  
  def get_item_data(options)
    option_string = parse_options(options)
    
    response_xml = open("http://api.feedburner.com/awareness/1.0/GetItemData?#{option_string}").read
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
          end
        end
      end
    end
    
    return response
  end
  
  public
  class Response
    attr_accessor :status, :code, :message, :feeds
    
    def initialize
      @feeds = []
    end
    
    def to_s
      output = []
      output << "Status: #{@status}"
      output << "Code: #{@code}" if @code
      output << "Message: #{@message}" if @message
      for feed in @feeds
        output << "-Feed"
        output << "\t Id: #{feed.id}" if feed.id
        output << "\t URI: #{feed.uri}" if feed.uri
        for entry in feed.entries
          output << "\t-Entry"
          output << "\t\t Date: #{entry.date}" if entry.date
          output << "\t\t Circulation: #{entry.circulation}" if entry.circulation
          output << "\t\t Hits: #{entry.hits}" if entry.hits
          for item in entry.items
            output << "\t\t-Item"
            output << "\t\t\tTitle: #{item.title}" if item.title
            output << "\t\t\tURL: #{item.url}" if item.url
            output << "\t\t\tItemViews: #{item.itemviews}" if item.itemviews
            output << "\t\t\tClickthoughs: #{item.clickthroughs}" if item.clickthroughs
          end
        end
      end
      
      return output.join("\n")
    end
  end
  
  class Feed
    attr_accessor :id, :uri, :entries
    
    def initialize
      @entries = []
    end
  end
  
  class Entry
    attr_accessor :date, :circulation, :hits, :items
    
    def initialize
      @items = []
    end
  end
  
  class Item
    attr_accessor :title, :url, :itemviews, :clickthroughs
  end
end

# rawapi = AwarenessApi.new
# opts = {:uri => 'CommonThread', :dates => '2007-01-18,2007-01-21'}
# 
# puts rawapi.get_feed_data(opts)
# puts rawapi.get_item_data(opts)