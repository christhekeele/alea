defmodule Dice do
  def expression(expression) do
    expression |> Dice.Expression.new
  end

  def roll(expression) do
    expression |> Dice.Expression.new |> Dice.Expression.evaluate
  end
end
