defmodule OrderBook do
  alias OrderBook.Entities.{OrderItem, OrderBook}

  def trigger(state, order) do
    cond do
      order["command"] == "sell" -> buy(state, order)
      order["command"] == "buy" -> sell(state, order)
    end

    # %OrderBook{buy: [], sell: []}
  end

  def buy(state, order) do
    IO.puts("buying")

    order_found = state.sell |> Enum.find(fn val -> val.price == order["price"] end)

    IO.puts("buy method - order_found ::")
    IO.inspect(order_found)

    order_duplicate_price_found =
      state.sell |> Enum.find(fn val -> val.price == order["price"] end)

    IO.puts("order_duplicate_price_found ::")
    IO.inspect(order_duplicate_price_found)

    order_ready_buy_found = state.buy |> Enum.find(fn val -> val.price >= order["price"] end)

    IO.puts("order_ready_buy_found ::")
    IO.inspect(order_ready_buy_found)

    {ok, list} =
      cond do
        order_found == nil and order_duplicate_price_found != nil and
            !Enum.empty?(state.sell) ->
          IO.puts("Case 1")

          calculated_volume = order_duplicate_price_found.volume + order["amount"]
          new_order_item = %OrderItem{order_duplicate_price_found | volume: calculated_volume}
          [new_order_item | state.sell] |> Enum.uniq_by(fn o -> o.price end)

        order_found == nil and order_duplicate_price_found == nil and
          order_ready_buy_found == nil and
            Enum.empty?(state.sell) ->
          IO.puts("Case 2")
          {true, [%OrderItem{price: order["price"], volume: order["amount"]} | state.sell]}

        order_found == nil and order_duplicate_price_found == nil and order_ready_buy_found == nil and
            !Enum.empty?(state.sell) ->
          IO.puts("Case 3")
          {true, [%OrderItem{price: order["price"], volume: order["amount"]} | state.sell]}

        true ->
          IO.puts("🔥 buy method Case true only")
          {false, nil}
      end

    # |> Enum.sort_by(fn o -> o.price end, :asc)

    if(ok == true) do
      IO.puts("buy condition ok == true")
      IO.inspect(list)
      %OrderBook{state | sell: list |> Enum.sort_by(fn o -> o.price end, :asc)}
    else
      IO.puts("🔴buy  ok == false #{order_ready_buy_found.volume} , #{order["amount"]}")
      calculate_volume = (order_ready_buy_found.volume - order["amount"]) |> Float.round(3)
      IO.puts("price #{calculate_volume}")

      if calculate_volume <= 0 do
        new_state = %OrderBook{
          state
          | buy:
              state.buy
              |> Enum.filter(fn o -> o.price != order_ready_buy_found.price end)
              |> Enum.uniq_by(fn o -> o.price end)
        }

        buy(new_state, %{"price" => order["price"], "amount" => calculate_volume * -1})
      else
        new_order_item = %OrderItem{order_ready_buy_found | volume: calculate_volume}
        %OrderBook{state | buy: [new_order_item | state.buy] |> Enum.uniq_by(fn o -> o.price end)}
      end
    end
  end

  def sell(state, order) do
    IO.puts("sell method 🎉")
    order_found = state.sell |> Enum.find(fn val -> val.price == order["price"] end)
    IO.puts("order_found ::")
    IO.inspect(order_found)

    order_duplicate_price_found =
      state.buy |> Enum.find(fn val -> val.price == order["price"] end)

    IO.puts("order_duplicate_price_found ::")
    IO.inspect(order_duplicate_price_found)

    order_ready_sell_found = state.sell |> Enum.find(fn val -> val.price <= order["price"] end)

    IO.puts("order_ready_sell_found ::")
    IO.inspect(order_ready_sell_found)

    {ok, list} =
      cond do
        order_found == nil and order_duplicate_price_found != nil and
            !Enum.empty?(state.buy) ->
          IO.puts("Sell Case 1")

          calculated_volume = order_duplicate_price_found.volume + order["amount"]
          new_order_item = %OrderItem{order_duplicate_price_found | volume: calculated_volume}
          {true, [new_order_item | state.buy] |> Enum.uniq_by(fn o -> o.price end)}

        order_found == nil and order_duplicate_price_found == nil and
          order_ready_sell_found == nil and
            Enum.empty?(state.buy) ->
          IO.puts("Sell Case 2")

          {true, [%OrderItem{price: order["price"], volume: order["amount"]} | state.buy]}

        order_found == nil and order_duplicate_price_found == nil and
          order_ready_sell_found == nil and
            !Enum.empty?(state.buy) ->
          IO.puts("Sell Case 3")
          {true, [%OrderItem{price: order["price"], volume: order["amount"]} | state.buy]}

        true ->
          IO.puts("🔥 sell method Case true only")
          {false, nil}
      end

    if ok == true do
      %OrderBook{state | buy: list |> Enum.sort_by(fn o -> o.price end, :desc)}
    else
      IO.puts("🔴 sell ok == false #{order_ready_sell_found.volume} , #{order["amount"]}")
      calculate_volume = (order_ready_sell_found.volume - order["amount"]) |> Float.round(3)

      if calculate_volume <= 0 do
        new_state = %OrderBook{
          state
          | sell:
              state.sell
              |> Enum.filter(fn o -> o.price != order_ready_sell_found.price end)
              |> Enum.uniq_by(fn o -> o.price end)
        }

        IO.puts("before recursive....")
        update_order_volume = %{"price" => order["price"], "amount" => calculate_volume * -1}
        IO.inspect(update_order_volume)
        sell(new_state, update_order_volume)
      else
        new_order_item = %OrderItem{order_ready_sell_found | volume: calculate_volume}

        %OrderBook{
          state
          | sell: [new_order_item | state.sell] |> Enum.uniq_by(fn o -> o.price end)
        }
      end
    end

    # IO.puts("---------------------")
    # %OrderBook{state | buy: result}
  end

  def main do
    # 1
    # json_str =
    #   '{ "orders": [ {"command": "sell", "price": 100.003, "amount": 2.4}, {"command": "buy", "price": 90.394, "amount": 3.445} ] }'

    # 2
    # json_str =
    #   '{"orders":[{"command":"sell","price":100.003,"amount":2.4},{"command":"buy","price":90.394,"amount":3.445},{"command":"buy","price":89.394,"amount":4.3},{"command":"sell","price":100.013,"amount":2.2},{"command":"buy","price":90.15,"amount":1.305},{"command":"buy","price":90.394,"amount":1.0}]}'

    # 3
    # json_str =
    #   '{"orders":[{"command":"sell","price":100.003,"amount":2.4},{"command":"buy","price":90.394,"amount":3.445},{"command":"buy","price":89.394,"amount":4.3},{"command":"sell","price":100.013,"amount":2.2},{"command":"buy","price":90.15,"amount":1.305},{"command":"buy","price":90.394,"amount":1.0},{"command":"sell","price":90.394,"amount":2.2}]}'

    # 4
    # json_str =
    #   '{"orders":[{"command":"sell","price":100.003,"amount":2.4},{"command":"buy","price":90.394,"amount":3.445},{"command":"buy","price":89.394,"amount":4.3},{"command":"sell","price":100.013,"amount":2.2},{"command":"buy","price":90.15,"amount":1.305},{"command":"buy","price":90.394,"amount":1.0},{"command":"sell","price":90.394,"amount":2.2},{"command":"sell","price":90.15,"amount":3.4},{"command":"buy","price":91.33,"amount":1.8},{"command":"buy","price":100.01,"amount":4.0},{"command":"sell","price":100.15,"amount":3.8}]}'

    json_str = '{
      "orders": [
        {"command": "sell", "price": 100.003, "amount": 2.4},
        {"command": "buy", "price": 90.394, "amount": 3.445},
        {"command": "buy", "price": 89.394, "amount": 4.3},
        {"command": "sell", "price": 100.013, "amount": 2.2},
        {"command": "buy", "price": 90.15, "amount": 1.305},
        {"command": "buy", "price": 90.394, "amount": 1.0},
        {"command": "sell", "price": 90.394, "amount": 2.2},
        {"command": "sell", "price": 90.15, "amount": 3.4},
        {"command": "buy", "price": 91.33, "amount": 1.8},
        {"command": "buy", "price": 100.01, "amount": 4.0},
        {"command": "sell", "price": 100.15, "amount": 3.8}

      ]
   }'

    {_, inputs} = Poison.decode(json_str)

    current_list =
      Enum.reduce(inputs["orders"], %OrderBook{buy: [], sell: []}, fn order, acc ->
        o_price = order["price"]
        o_amount = order["amount"]
        o_command = order["command"]
        IO.puts("starting trigger 🔥 #{o_price}, amount #{o_amount} #{o_command} end")
        result = trigger(acc, order)
        IO.inspect(result)
        %OrderBook{acc | buy: result.buy, sell: result.sell}
      end)

    IO.puts("🟢 final value")
    current_list
  end
end
