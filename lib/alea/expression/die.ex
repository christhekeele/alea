defmodule Alea.Expression.Die do
  defstruct [:sides]

  @symbol "d"
  @compile {:inline, symbol: 0}
  def symbol, do: @symbol

  import Alea.Expression.Parser.Builder

  defparser do
    ignore(string(@symbol))
    |> concat(unwrap_and_tag(parsec({Alea.Expression.Die.Sides.Parser, :combinator}), :sides))
    |> post_traverse({__MODULE__, :from_parse, []})
  end

  def from_parse(unparsed, parsed, context, _line, _offset) do
    sides = Keyword.fetch!(parsed, :sides)

    die = %__MODULE__{sides: sides}

    {unparsed, [die], context}
  end

  def to_string(%Alea.Expression.Die{} = die) do
    "#{@symbol}#{die.sides}"
  end

  defimpl String.Chars do
    def to_string(%Alea.Expression.Die{} = die) do
      Alea.Expression.Die.to_string(die)
    end
  end
end
