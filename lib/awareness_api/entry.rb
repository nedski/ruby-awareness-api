module AwarenessApi
  class Entry
    include FeedAttributes

    def initialize
      @items = []
    end
  end
end