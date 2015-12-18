require "date"

class User
  attr_reader :first_name, :last_name, :created_at

  def initialize(first_name, last_name)
    raise TypeError unless first_name.is_a?(String)
    raise TypeError unless last_name.is_a?(String)
    raise ArgumentError unless first_name.length > 0
    raise ArgumentError unless last_name.length > 0
    @first_name = first_name
    @last_name = last_name
    @created_at = DateTime.new
  end

  def to_s
    "#{first_name} #{last_name}"
  end
end
