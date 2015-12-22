require "bigdecimal"
require "test/unit"
require "test/unit/ui/console/testrunner"
require_relative "../application"
require_relative "../models/bid"

class CreationTestCase < Test::Unit::TestCase
  def setup
    @app = Application.new
  end

  def test_valid_create_auctioneer
    first_name = "Matt"
    last_name = "Palen"
    @app.create_auctioneer(first_name, last_name)
    auctioneer = @app.get_auctioneer(first_name, last_name)

    assert_equal("Matt", auctioneer.first_name)
    assert_equal("Palen", auctioneer.last_name)
  end

  def test_duplicate_auctioneer_creation
    first_name = "Matt"
    last_name = "Palen"
    @app.create_auctioneer(first_name, last_name)

    assert_raise AuctioneerAlreadyExistsError do
      @app.create_auctioneer(first_name, last_name)
    end
  end

  def test_valid_create_bidder
    first_name = "Matt"
    last_name = "Palen"
    @app.create_bidder(first_name, last_name)
    bidder = @app.get_bidder(first_name, last_name)

    assert_equal("Matt", bidder.first_name)
    assert_equal("Palen", bidder.last_name)
  end

  def test_duplicate_bidder_creation
    first_name = "Matt"
    last_name = "Palen"
    @app.create_bidder(first_name, last_name)

    assert_raise BidderAlreadyExistsError do
      @app.create_bidder(first_name, last_name)
    end
  end

  def test_valid_create_item
    name = "Shovel"
    description = "Greatest shovel on earth"
    @app.create_item(name, description)
    item = @app.get_item(name)

    assert_equal(name, item.name)
    assert_equal(description, item.description)
  end

  def test_duplicate_item_creation
    name = "Shovel"
    description = "Greatest shovel on earth"
    @app.create_item(name, description)

    assert_raise ItemAlreadyExistsError do
      @app.create_item(name, description)
    end
  end

  def test_valid_create_auction
    auctioneer = Auctioneer.new("Matt", "Palen")
    item = Item.new("Shovel", "Greatest shovel on earth")
    reserved_price = 5
    @app.create_auction(auctioneer, item, reserved_price)
    auction = @app.get_auction(auctioneer, item)
    
    assert_equal(auctioneer, auction.auctioneer)
    assert_equal(item, auction.item)
    assert_equal(BigDecimal.new(reserved_price), auction.reserved_price)
  end

  def test_duplicate_auction_creation
    auctioneer = Auctioneer.new("Matt", "Palen")
    item = Item.new("Shovel", "Greatest shovel on earth")
    reserved_price = 5
    @app.create_auction(auctioneer, item, reserved_price)

    assert_raise AuctionAlreadyExistsError do
      @app.create_auction(auctioneer, item, reserved_price)
    end
  end

  def test_item_unavailable_create_auction
    auctioneer = Auctioneer.new("Matt", "Palen")
    item = Item.new("Shovel", "Greatest shovel on earth")
    item.available = false
    reserved_price = 5
    assert_raise ItemUnavailableError do
      @app.create_auction(auctioneer, item, reserved_price)
    end
  end
end

class BiddingTestCase < Test::Unit::TestCase
  def setup
    @app = Application.new

    @first_name1 = "Clark"
    @last_name1 = "Kent"
    
    @first_name2 = "Bruce"
    @last_name2 = "Wayne"

    @first_name3 = "Tony"
    @last_name3 = "Stark"

    @item_name = "MacBook Pro"
    @item_description = "A laptop"

    @app.create_auctioneer(@first_name1, @last_name1)
    @app.create_item(@item_name, @item_description)
    @app.create_bidder(@first_name2, @last_name2)
    @app.create_bidder(@first_name3, @last_name3)

    @auctioneer = @app.get_auctioneer(@first_name1, @last_name1)
    @item = @app.get_item(@item_name)
    @reserved_price = 500
    @app.create_auction(@auctioneer, @item, @reserved_price)

    @auction = @app.get_auction(@auctioneer, @item)
    @bidder1 = @app.get_bidder(@first_name2, @last_name2)
    @bidder2 = @app.get_bidder(@first_name3, @last_name3)
  end

  def test_not_yet_started_bid
    bid = Bid.new(@bidder1, @reserved_price + 1)
    
    assert_raise NotYetStartedError do
      @auction.accept_bid(bid)
    end
  end

  def test_single_bid
    @auction.start
    
    bid = Bid.new(@bidder1, @reserved_price + 1)
    @auction.accept_bid(bid)
    
    assert_equal(bid, @auction.bids[-1])
    # Should save to @app.auctions here
  end

  def test_two_bids
    @auction.start
    
    bid1 = Bid.new(@bidder1, @reserved_price + 1)
    @auction.accept_bid(bid1)

    bid2 = Bid.new(@bidder2, @reserved_price + 2)
    @auction.accept_bid(bid2)

    assert_equal(bid2, @auction.bids[-1])
  end

  def test_three_bids
    @auction.start

    bid1 = Bid.new(@bidder1, @reserved_price + 1)
    @auction.accept_bid(bid1)

    bid2 = Bid.new(@bidder2, @reserved_price + 2)
    @auction.accept_bid(bid2)

    bid3 = Bid.new(@bidder1, @reserved_price + 3)
    @auction.accept_bid(bid3)

    assert_equal(bid3, @auction.bids[-1])
  end

  def test_uncompetitive_bid_price
    @auction.start

    bid1 = Bid.new(@bidder1, 300)
    bid2 = Bid.new(@bidder2, 299)
    @auction.accept_bid(bid1)
    
    assert_raise InvalidMinimumBidPriceError do
      @auction.accept_bid(bid2)
    end
  end

  def test_no_bids_auction
    @auction.start
    @auction.end

    assert_equal(false, @auction.success)
    assert_equal(false, @auction.item.available)
  end

  def test_failed_auction
    @auction.start
    bid = Bid.new(@bidder1, 300)
    @auction.accept_bid(bid)
    @auction.end

    assert_equal(false, @auction.success)
    assert_equal(false, @auction.item.available)
  end

  def test_success_auction
    @auction.start
    bid = Bid.new(@bidder1, @reserved_price + 1)
    @auction.accept_bid(bid)
    @auction.end

    @app.debug_auction(@auction)

    assert_equal(true, @auction.success)
    assert_equal(false, @auction.item.available)
  end
end
