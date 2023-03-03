defmodule Dice do
  def expression(string) when is_binary(string) do
    string |> Dice.Expression.new()
  end

  def roll(string) when is_binary(string) do
    string |> expression |> Dice.Expression.evaluate()
  end
end
