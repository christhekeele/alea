defmodule Dice.Die do
  defstruct [:sides]

  @symbol "d"
  @compile {:inline, symbol: 0}
  def symbol, do: @symbol

  import Dice.Parser.Builder

  defparser do
    ignore(string(@symbol))
    |> concat(unwrap_and_tag(parsec({Dice.Die.Sides.Parser, :combinator}), :sides))
    |> post_traverse({__MODULE__, :from_parse, []})
  end

  def from_parse(unparsed, parsed, context, _line, _offset) do
    sides = Keyword.fetch!(parsed, :sides)

    die = %__MODULE__{sides: sides}

    {unparsed, [die], context}
  end

  defimpl Dice.Expression.Evaluate do
    def evaluate(%Dice.Die{} = die) do
      Dice.Die.Sides.random(die.sides)
    end
  end

  defimpl String.Chars do
    def to_string(%Dice.Die{} = die) do
      Dice.Die.symbol() <> Kernel.to_string(die.sides)
    end
  end
end
