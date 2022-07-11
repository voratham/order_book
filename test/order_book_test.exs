defmodule OrderBookTest do
  use ExUnit.Case
  doctest OrderBook

  def convertJsonToStruct(json) do
    Poison.decode!(json,
      as: %OrderBook.Entities.OrderBook{
        buy: [%OrderBook.Entities.OrderItem{price: nil, volume: nil}],
        sell: [%OrderBook.Entities.OrderItem{price: nil, volume: nil}]
      }
    )
  end

  test "should return result correctly with input 1" do
    input =
      '{ "orders": [ {"command": "sell", "price": 100.003, "amount": 2.4}, {"command": "buy", "price": 90.394, "amount": 3.445} ] }'

    assert OrderBook.main(input) ==
             convertJsonToStruct(
               ~s({"buy":[{"price":90.394,"volume":3.445}],"sell":[{"price":100.003,"volume":2.4}]})
             )
  end

  test "should return result correctly with input 2" do
    input =
      '{"orders":[{"command":"sell","price":100.003,"amount":2.4},{"command":"buy","price":90.394,"amount":3.445},{"command":"buy","price":89.394,"amount":4.3},{"command":"sell","price":100.013,"amount":2.2},{"command":"buy","price":90.15,"amount":1.305},{"command":"buy","price":90.394,"amount":1.0}]}'

    assert OrderBook.main(input) ==
             convertJsonToStruct(
               ~s({"buy":[{"price":90.394,"volume":4.445},{"price":90.15,"volume":1.305},{"price":89.394,"volume":4.3}],"sell":[{"price":100.003,"volume":2.4},{"price":100.013,"volume":2.2}]})
             )
  end

  test "should return result correctly with input 3" do
    input =
      '{"orders":[{"command":"sell","price":100.003,"amount":2.4},{"command":"buy","price":90.394,"amount":3.445},{"command":"buy","price":89.394,"amount":4.3},{"command":"sell","price":100.013,"amount":2.2},{"command":"buy","price":90.15,"amount":1.305},{"command":"buy","price":90.394,"amount":1.0},{"command":"sell","price":90.394,"amount":2.2}]} '

    assert OrderBook.main(input) ==
             convertJsonToStruct(
               ~s({"buy":[{"price":90.394,"volume":2.245},{"price":90.15,"volume":1.305},{"price":89.394,"volume":4.3}],"sell":[{"price":100.003,"volume":2.4},{"price":100.013,"volume":2.2}]})
             )
  end

  test "should return result correctly with input 4" do
    input =
      '{"orders":[{"command":"sell","price":100.003,"amount":2.4},{"command":"buy","price":90.394,"amount":3.445},{"command":"buy","price":89.394,"amount":4.3},{"command":"sell","price":100.013,"amount":2.2},{"command":"buy","price":90.15,"amount":1.305},{"command":"buy","price":90.394,"amount":1.0},{"command":"sell","price":90.394,"amount":2.2},{"command":"sell","price":90.15,"amount":3.4},{"command":"buy","price":91.33,"amount":1.8},{"command":"buy","price":100.01,"amount":4.0},{"command":"sell","price":100.15,"amount":3.8}]}'

    assert OrderBook.main(input) ==
             convertJsonToStruct(
               ~s({"buy":[{"price":100.01,"volume":1.6},{"price":91.33,"volume":1.8},{"price":90.15,"volume":0.15},{"price":89.394,"volume":4.3}],"sell":[{"price":100.013,"volume":2.2},{"price":100.15,"volume":3.8}]})
             )
  end

  test "should return result correctly with input 5" do
    input =
      '{"orders":[{"command":"sell","price":100.003,"amount":10},{"command":"buy","price":90.394,"amount":10},{"command":"buy","price":90.394,"amount":10},{"command":"buy","price":100.15,"amount":10}]}'

    assert OrderBook.main(input) ==
             convertJsonToStruct(~s({"buy":[{"price":90.394,"volume":20}],"sell":[]}))
  end

  test "should return result correctly with input 6" do
    input =
      '{"orders":[{"command":"buy","price":100.003,"amount":10},{"command":"sell","price":90.394,"amount":10},{"command":"sell","price":90.394,"amount":10},{"command":"sell","price":100.15,"amount":10}]}'

    assert OrderBook.main(input) ==
             convertJsonToStruct(
               ~s({"buy":[],"sell":[{"price":90.394,"volume":10},{"price":100.15,"volume":10}]})
             )
  end

  test "should return result correctly with input 7" do
    input =
      '{"orders":[{"command":"sell","price":100.003,"amount":30},{"command":"buy","price":90.394,"amount":10},{"command":"buy","price":90.394,"amount":10},{"command":"buy","price":100.15,"amount":10}]}'

    assert OrderBook.main(input) ==
             convertJsonToStruct(~s({"buy":[{"price":90.394,"volume":20}],"sell":[{"price":100.003,"volume":20}]}))
  end
end
