class Item
  attr_accessor :title, :url, :itemviews, :clickthroughs, :referers
  
  def initialize
    @referers = []
  end
end