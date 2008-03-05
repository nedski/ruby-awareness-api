# The Response object is the ruby object version of the webservice response.
module AwarenessApi
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
            for referer in item.referers
              output << "      -Referer"
              referer.attributes.each do |key,val|
                output << "        #{key}: #{val}"
              end
            end
          end
        end
      end

      return output.join("\n")
    end
  end
end