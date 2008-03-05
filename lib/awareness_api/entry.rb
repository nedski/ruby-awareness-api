module AwarenessApi
  class Entry
    include AwarenessApi::FeedAttributes

    def initialize
      @items = []
    end
  end
end