module AwarenessApi
  class Feed
    include FeedAttributes

    attr_accessor :id

    def initialize
      @entries = []
    end
  end
end