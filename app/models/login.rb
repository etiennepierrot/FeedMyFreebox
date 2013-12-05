class Login
  attr_reader :host, :key
  def initialize(host, key)
    @host = host
    @key = key
  end
end