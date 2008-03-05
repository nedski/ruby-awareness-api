require 'lib/awareness_api'

opts = {:uri => 'CommonThread'}

puts AwarenessApi.get_feed_data(opts)
puts AwarenessApi.get_item_data(opts)
puts AwarenessApi.get_resyndication_data(opts)