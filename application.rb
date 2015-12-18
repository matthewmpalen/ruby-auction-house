require_relative "models/auction"
require_relative "models/auctioneer"
require_relative "models/bidder"

class AlreadyExistsError < StandardError
end

class AuctioneerAlreadyExistsError < AlreadyExistsError
end

class BidderAlreadyExistsError < AlreadyExistsError
end

class ItemAlreadyExistsError < AlreadyExistsError
end

class AuctionAlreadyExistsError < AlreadyExistsError
end

class Application
  def initialize
    @auctioneers = Hash.new
    @bidders = Hash.new
    @items = Hash.new
    @auctions = Hash.new
  end

  def create_auctioneer(first_name, last_name)
    auctioneer = get_auctioneer(first_name, last_name)
    raise AuctioneerAlreadyExistsError unless auctioneer.nil?
    auctioneer = Auctioneer.new(first_name, last_name)
    @auctioneers[[first_name, last_name]] = auctioneer
  end

  def get_auctioneer(first_name, last_name)
    @auctioneers[[first_name, last_name]]
  end

  def create_bidder(first_name, last_name)
    bidder = get_bidder(first_name, last_name)
    raise BidderAlreadyExistsError unless bidder.nil?
    bidder = Bidder.new(first_name, last_name)
    @bidders[[first_name, last_name]] = bidder
  end

  def get_bidder(first_name, last_name)
    @bidders[[first_name, last_name]]
  end

  def create_item(name, description)
    item = get_item(name)
    raise ItemAlreadyExistsError unless item.nil?
    item = Item.new(name, description)
    @items[name] = item
  end

  def get_item(name)
    @items[name]
  end

  def create_auction(auctioneer, item, price)
    auction = get_auction(auctioneer, item)
    raise AuctionAlreadyExistsError unless auction.nil?
    auction = Auction.new(auctioneer, item, price)
    @auctions[[auctioneer, item]] = auction
  end

  def get_auction(auctioneer, item)
    @auctions[[auctioneer, item]]
  end

  def debug_auction(auction)
    if auction.success
      bid = auction.bids[-1]
      puts "#{auction.item.name} was sold to #{bid.bidder} for #{bid.price}"
    else
      puts "#{auction}"
    end
  end
end
