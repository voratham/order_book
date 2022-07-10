defmodule OrderBook do
  alias OrderBook.Entities.OrderBook

  @state %OrderBook{buy: [], sell: []}

  def init do
    @state
  end
end
