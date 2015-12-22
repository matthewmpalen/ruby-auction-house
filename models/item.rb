#########
# Models
#########

class Item
  # Model which represents the concrete item for sale in an auction
  attr_accessor :available
  attr_reader :name, :description, :created_at

  def initialize(name, description)
    @name = name
    @description = description
    @available = true
    @created_at = DateTime.new
  end
end
