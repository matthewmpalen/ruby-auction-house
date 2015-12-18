require "bigdecimal"
require_relative "item"

class AlreadyEndedError < StandardError
end

class AlreadyStartedError < StandardError
end

class ItemUnavailableError < StandardError
end

class InvalidMinimumBidPriceError < StandardError
end

class NotYetStartedError < StandardError
end

class Auction
  attr_reader :auctioneer, :item, :reserved_price, :bids
  attr_reader :start_time, :end_time, :success, :created_at

  def initialize(auctioneer, item, price)
    raise TypeError unless auctioneer.is_a?(Auctioneer)
    raise TypeError unless item.is_a?(Item)
    raise ArgumentError unless price > 0
    raise ItemUnavailableError unless item.available
    @auctioneer = auctioneer
    @item = item
    @reserved_price = BigDecimal.new(price)
    @bids = []
    @start_time = nil
    @end_time = nil
    @success = false
    @created_at = DateTime.now
  end

  def start
    raise AlreadyStartedError unless @start_time.nil?
    @start_time = DateTime.now
  end

  def accept_bid(bid)
    raise NotYetStartedError if @start_time.nil?

    if @bids.empty?
      @bids << bid
    else
      raise InvalidMinimumBidPriceError unless bid.price > @bids[-1].price
      @bids << bid
    end
  end

  def end
    raise AlreadyEndedError unless @end_time.nil?
    @end_time = DateTime.now
    @item.available = false
    return if @bids.empty?

    if @bids[-1].price > @reserved_price
      @success = true
    end
  end

  def to_s
    "#{@item.name}: #{@start_time} - #{@end_time} (#{@success})"
  end
end
