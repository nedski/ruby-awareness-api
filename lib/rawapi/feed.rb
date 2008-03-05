class Feed
  attr_accessor :id, :uri, :entries
  
  def initialize
    @entries = []
  end
end