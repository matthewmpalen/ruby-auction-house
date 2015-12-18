require "bigdecimal"

class Bid
  attr_reader :bidder, :price

  def initialize(bidder, price)
    raise TypeError unless bidder.is_a?(Bidder)
    raise ArgumentError unless price > 0
    @bidder = bidder
    @price = BigDecimal.new(price)
    @created_at = DateTime.new
  end
end
