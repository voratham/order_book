defmodule OrderBook.Entities.OrderBook do
  @enforce_keys [:buy, :sell]
  defstruct buy: [], sell: []
end
