defmodule Alea.Expression.Die.Sides.Range do
  defstruct [:first, :last]

  @symbol ".."
  @compile {:inline, symbol: 0}
  def symbol, do: @symbol

  import Alea.Expression.Parser.Builder

  defparser do
    ignore(left_bracket_literal())
    |> concat(unwrap_and_tag(integer_literal(), :first))
    |> concat(ignore(string(@symbol)))
    |> concat(unwrap_and_tag(integer_literal(), :last))
    |> concat(right_bracket_literal())
    |> post_traverse({__MODULE__, :from_parse, []})
  end

  def from_parse(unparsed, parsed, context, _line, _offset) do
    first = Keyword.fetch!(parsed, :first)
    last = Keyword.fetch!(parsed, :last)

    range = %__MODULE__{first: first, last: last}

    {unparsed, [range], context}
  end

  defimpl String.Chars do
    def to_string(%Alea.Expression.Die.Sides.Range{} = range) do
      Enum.join([
        Integer.to_string(range.first),
        Alea.Expression.Die.Sides.Range.symbol(),
        Integer.to_string(range.last)
      ])
    end
  end
end
