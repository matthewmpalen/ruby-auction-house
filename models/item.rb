class Item
  attr_accessor :available
  attr_reader :name, :description, :created_at

  def initialize(name, description)
    @name = name
    @description = description
    @available = true
    @created_at = DateTime.new
  end
end
