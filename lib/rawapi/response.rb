# The Response object is the ruby object version of the webservice response.
class Response
  attr_accessor :status, :code, :message, :feeds
  
  def initialize
    @feeds = []
  end
  
  # returns a formated string representing the response object. good for debugging.
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
          for referer in item.referers
            output << "      -Referer"
            output << "        URL: #{referer.url}" if referer.url
            output << "        ItemViews: #{referer.itemviews}" if referer.itemviews
            output << "        Clickthoughs: #{referer.clickthroughs}" if referer.clickthroughs
          end
        end
      end
    end
    
    return output.join("\n")
  end
end