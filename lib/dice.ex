defmodule Dice do
  def expression(string) when is_binary(string) do
    string |> Dice.Expression.new()
  end

  def roll(%Dice.Expression{} = expression) do
    expression |> Dice.Expression.Evaluate.evaluate()
  end

  def roll(string) when is_binary(string) do
    string |> expression |> roll
  end
end
