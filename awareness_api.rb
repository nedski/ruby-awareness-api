require 'open-uri'
require 'rexml/document'
include REXML

# AwAPI docs at http://code.google.com/apis/feedburner/awareness_api.html

module AwarenessApi
  def self.get_feed_data(options)
    raise "options must include a feed id or uri" unless options[:id] or options[:uri]
    option_string = parse_options(options)

    response_xml = open("http://api.feedburner.com/awareness/1.0/GetFeedData?#{option_string}").read
    return parse_xml(response_xml)
  end

  def self.get_item_data(options)
    raise "options must include a feed uri" unless options[:uri]
    option_string = parse_options(options)

    response_xml = open("http://api.feedburner.com/awareness/1.0/GetItemData?#{option_string}").read
    return parse_xml(response_xml)
  end

  def self.get_resyndication_data(options)
    raise "options must include a feed uri" unless options[:uri]
    option_string = parse_options(options)

    response_xml = open("http://api.feedburner.com/awareness/1.0/GetResyndicationData?#{option_string}").read
    return parse_xml(response_xml)
  end

  private
  def self.parse_options(options)
    options[:uri] = nil if options[:id] and options[:uri]

    return options.collect {|key, value| "#{key}=#{value}" unless value.nil?}.compact.join('&')
  end

  def self.parse_xml(response_xml)
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

        response.feeds << feed

        for entry_node in feed_node.elements
          entry = Entry.new

          entry_node.attributes.each do |key,value|
            entry.send(key+"=", value)
          end

          feed.entries << entry

          for item_node in entry_node.elements
            item = Item.new

            item_node.attributes.each do |key,value|
              item.send(key+"=", value)
            end

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
        feed.attributes.each do |key,val|
          output << "  #{key}: #{val}"
        end
        for entry in feed.entries
          output << "  -Entry"
          entry.attributes.each do |key,val|
            output << "    #{key}: #{val}"
          end
          for item in entry.items
            output << "    -Item"
            item.attributes.each do |key,val|
              output << "      #{key}: #{val}"
            end
          end
        end
      end

      return output.join("\n")
    end
  end

  module FeedAttributes
    def attributes
      attribute_hash = {}

      self.instance_variables.each do |var|
        var_symbol = var[1..-1].to_sym
        attribute_hash[var_symbol] = self.send(var_symbol) unless self.send(var_symbol).is_a?(Array)
      end

      attribute_hash
    end

    def method_missing(method, *params, &block)
      method = method.to_s
      if method =~ /=/
        self.instance_variable_set("@#{method[0..-2]}", params[0])
      else
        self.instance_variable_get("@#{method}")
      end
    end
  end

  class Feed
    include FeedAttributes

    attr_accessor :id

    def initialize
      @entries = []
    end
  end

  class Entry
    include FeedAttributes

    def initialize
      @items = []
    end
  end

  class Item
    include FeedAttributes
  end
end
