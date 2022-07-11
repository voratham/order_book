defmodule OrderBook do
  alias OrderBook.Entities.{OrderItem, OrderBook, OrderRequest}

  defp find_order_by_price(list, order) do
    Enum.find(list, fn val -> val.price == order["price"] end)
  end

  defp calculate_volume_by_order_matching(order_matching_price, order_request) do
    ((order_matching_price.volume - order_request["amount"]) / 1) |> Float.round(3)
  end

  defp buy(state, order) do
    order_found = state.sell |> find_order_by_price(order)
    order_duplicate_price_found = state.sell |> find_order_by_price(order)
    order_ready_buy_found = state.buy |> Enum.find(fn val -> val.price >= order["price"] end)

    {ok, list} =
      cond do
        order_found == nil and order_duplicate_price_found == nil and
          order_ready_buy_found == nil and (Enum.empty?(state.sell) or !Enum.empty?(state.sell)) ->
          {true, [%OrderItem{price: order["price"], volume: order["amount"]} | state.sell]}

        true ->
          {false, nil}
      end

    if(ok == true) do
      %OrderBook{state | sell: list |> Enum.sort_by(fn o -> o.price end, :asc)}
    else
      calculate_volume = calculate_volume_by_order_matching(order_ready_buy_found, order)

      if calculate_volume <= 0 do
        new_state = %OrderBook{
          state
          | buy:
              state.buy
              |> Enum.filter(fn o -> o.price != order_ready_buy_found.price end)
              |> Enum.uniq_by(fn o -> o.price end)
        }

        if calculate_volume == 0 do
          new_state
        else
          update_order_volume = %{"price" => order["price"], "amount" => calculate_volume * -1}
          buy(new_state, update_order_volume)
        end
      else
        new_order_item = %OrderItem{order_ready_buy_found | volume: calculate_volume}
        %OrderBook{state | buy: [new_order_item | state.buy] |> Enum.uniq_by(fn o -> o.price end)}
      end
    end
  end

  defp sell(state, order) do
    order_found = state.sell |> find_order_by_price(order)
    order_duplicate_price_found = state.buy |> find_order_by_price(order)
    order_ready_sell_found = state.sell |> Enum.find(fn val -> val.price <= order["price"] end)

    {ok, list} =
      cond do
        order_found == nil and order_duplicate_price_found != nil and
            !Enum.empty?(state.buy) ->
          calculated_volume = order_duplicate_price_found.volume + order["amount"]
          new_order_item = %OrderItem{order_duplicate_price_found | volume: calculated_volume}
          {true, [new_order_item | state.buy] |> Enum.uniq_by(fn o -> o.price end)}

        order_found == nil and order_duplicate_price_found == nil and
          order_ready_sell_found == nil and (Enum.empty?(state.buy) or !Enum.empty?(state.buy)) ->
          {true, [%OrderItem{price: order["price"], volume: order["amount"]} | state.buy]}

        true ->
          {false, nil}
      end

    if ok == true do
      %OrderBook{state | buy: list |> Enum.sort_by(fn o -> o.price end, :desc)}
    else
      calculate_volume = calculate_volume_by_order_matching(order_ready_sell_found, order)

      if calculate_volume <= 0 do
        new_state = %OrderBook{
          state
          | sell:
              state.sell
              |> Enum.filter(fn o -> o.price != order_ready_sell_found.price end)
              |> Enum.uniq_by(fn o -> o.price end)
        }

        if calculate_volume == 0 do
          new_state
        else
          update_order_volume = %{"price" => order["price"], "amount" => calculate_volume * -1}
          sell(new_state, update_order_volume)
        end
      else
        new_order_item = %OrderItem{order_ready_sell_found | volume: calculate_volume}

        %OrderBook{
          state
          | sell: [new_order_item | state.sell] |> Enum.uniq_by(fn o -> o.price end)
        }
      end
    end
  end

  def trigger(state, order) do
    cond do
      order["command"] == "sell" -> buy(state, order)
      order["command"] == "buy" -> sell(state, order)
    end
  end

  def main(input) do
    case Poison.decode(input, as: %OrderRequest{orders: []}) do
      {:ok, inputs} ->
        case Enum.empty?(inputs.orders) do
          true ->
            {:error, "invalid input json"}

          false ->
            result =
              Enum.reduce(inputs.orders, %OrderBook{buy: [], sell: []}, fn order, acc ->
                result = trigger(acc, order)
                %OrderBook{acc | buy: result.buy, sell: result.sell}
              end)

            {:ok, result}
        end

      {:error, _} ->
        {:error, "invalid input json"}
    end
  end
end
