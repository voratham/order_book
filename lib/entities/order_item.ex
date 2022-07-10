defmodule OrderBook.Entities.OrderItem do
  @enforce_keys [:price, :volume]
  defstruct [:price, :volume]
end
