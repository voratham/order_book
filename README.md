# OrderBook

**This is challenge from zipmex**

```sh
mix deps.get
make test-coverage # generate coverage
iex -S mix
```

**Example run on iex**
```elixir
OrderBook.main('{"orders":[{"command":"sell","price":100.003,"amount":2.4},{"command":"buy","price":90.394,"amount":3.445},{"command":"buy","price":89.394,"amount":4.3},{"command":"sell","price":100.013,"amount":2.2},{"command":"buy","price":90.15,"amount":1.305},{"command":"buy","price":90.394,"amount":1.0},{"command":"sell","price":90.394,"amount":2.2},{"command":"sell","price":90.15,"amount":3.4},{"command":"buy","price":91.33,"amount":1.8},{"command":"buy","price":100.01,"amount":4.0},{"command":"sell","price":100.15,"amount":3.8}]}')

{:ok,
 %OrderBook.Entities.OrderBook{
   buy: [
     %OrderBook.Entities.OrderItem{price: 100.01, volume: 1.6},
     %OrderBook.Entities.OrderItem{price: 91.33, volume: 1.8},
     %OrderBook.Entities.OrderItem{price: 90.15, volume: 0.15},
     %OrderBook.Entities.OrderItem{price: 89.394, volume: 4.3}
   ],
   sell: [
     %OrderBook.Entities.OrderItem{price: 100.013, volume: 2.2},
     %OrderBook.Entities.OrderItem{price: 100.15, volume: 3.8}
   ]
 }}

OrderBook.main('')                                                              {:error, "invalid input json"}

```


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `order_book` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:order_book, "~> 0.1.0"}
  ]
end
```
