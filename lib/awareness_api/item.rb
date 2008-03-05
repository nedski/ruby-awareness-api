module AwarenessApi
  class Item
    include FeedAttributes

    def initialize
      @referers = []
    end
  end
end
