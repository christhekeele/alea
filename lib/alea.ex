defmodule Alea do
  def expression(string) when is_binary(string) do
    string |> Alea.Expression.new()
  end

  def roll(%Alea.Expression{} = expression) do
    expression |> Alea.Expression.Evaluate.evaluate()
  end

  def roll(string) when is_binary(string) do
    string |> expression |> roll
  end
end
