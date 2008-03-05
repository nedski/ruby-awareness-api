module AwarenessApi
  class Item
    include AwarenessApi::FeedAttributes

    def initialize
      @referers = []
    end
  end
end
