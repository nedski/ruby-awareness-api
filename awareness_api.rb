require 'open-uri'
require 'rexml/document'
include REXML

# AwAPI docs at http://code.google.com/apis/feedburner/awareness_api.html

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
        
        feed_node.attributes.each do |key,value|
          feed.send(key+"=", value)
        end
        
        # feed.id = feed_node.attributes['id']
        # feed.uri = feed_node.attributes['uri']
        
        response.feeds << feed
        
        for entry_node in feed_node.elements
          entry = Entry.new
          
          entry_node.attributes.each do |key,value|
            entry.send(key+"=", value)
          end
          
          # entry.date = entry_node.attributes['date']
          # entry.circulation = entry_node.attributes['circulation']
          # entry.hits = entry_node.attributes['hits']
          
          feed.entries << entry
          
          for item_node in entry_node.elements
            item = Item.new
            
            item_node.attributes.each do |key,value|
              item.send(key+"=", value)
            end
            
            # item.title = item_node.attributes['title']
            # item.url = item_node.attributes['url']
            # item.itemviews = item_node.attributes['itemviews']
            # item.clickthroughs = item_node.attributes['clickthroughs']
            
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
        output << "  Id: #{feed.id}" if feed.id
        output << "  URI: #{feed.uri}" if feed.uri
        for entry in feed.entries
          output << "  -Entry"
          output << "    Date: #{entry.date}" if entry.date
          output << "    Circulation: #{entry.circulation}" if entry.circulation
          output << "    Hits: #{entry.hits}" if entry.hits
          for item in entry.items
            output << "    -Item"
            output << "      Title: #{item.title}" if item.title
            output << "      URL: #{item.url}" if item.url
            output << "      ItemViews: #{item.itemviews}" if item.itemviews
            output << "      Clickthoughs: #{item.clickthroughs}" if item.clickthroughs
          end
        end
      end
      
      return output.join("\n")
    end
  end
  
  class Feed
    attr_accessor :id
    
    def initialize
      @entries = []
      @attributes = []
    end
    
    def method_missing(method, *params, &block)
      method = method.to_s
      if method =~ /=/
        self.instance_variable_set("@#{method[0..-2]}", params)
      else
        self.instance_variable_get("@#{method}")
      end
    end
  end
  
  class Entry
    def initialize
      @items = []
    end
    
    def method_missing(method, *params, &block)
      method = method.to_s
      if method =~ /=/
        self.instance_variable_set("@#{method[0..-2]}", params)
      else
        self.instance_variable_get("@#{method}")
      end
    end
  end
  
  class Item
    def method_missing(method, *params, &block)
      method = method.to_s
      if method =~ /=/
        self.instance_variable_set("@#{method[0..-2]}", params)
      else
        self.instance_variable_get("@#{method}")
      end
    end
  end
end

rawapi = AwarenessApi.new
opts = {:uri => 'CommonThread'}

puts rawapi.get_feed_data(opts)
puts rawapi.get_item_data(opts)