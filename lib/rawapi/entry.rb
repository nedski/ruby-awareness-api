class Entry
  attr_accessor :date, :circulation, :hits, :items
  
  def initialize
    @items = []
  end
end