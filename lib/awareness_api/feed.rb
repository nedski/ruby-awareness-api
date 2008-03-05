module AwarenessApi
  class Feed
    include AwarenessApi::FeedAttributes

    attr_accessor :id

    def initialize
      @entries = []
    end
  end
end