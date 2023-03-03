defmodule Dice.Die.Sides.Range do
  defstruct [:first, :last]

  @symbol ".."
  @compile {:inline, symbol: 0}
  def symbol, do: @symbol

  import Dice.Parser.Builder

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

    range = __MODULE__.new(first, last)

    {unparsed, [range], context}
  end

  def new(first, last) when is_integer(first) and is_integer(last) do
    if first < last do
      %__MODULE__{first: first, last: last}
    else
      %__MODULE__{first: last, last: first}
    end
  end

  defimpl Dice.Die.Sides do
    def random(%Dice.Die.Sides.Range{} = range) do
      Range.new(range.first, range.last) |> Enum.random()
    end

    def min(%Dice.Die.Sides.Range{} = range) do
      range.first
    end

    def max(%Dice.Die.Sides.Range{} = range) do
      range.last
    end

    def count(%Dice.Die.Sides.Range{} = range) do
      range.first - range.last + 1
    end
  end

  defimpl String.Chars do
    def to_string(%Dice.Die.Sides.Range{} = range) do
      Enum.join([
        Integer.to_string(range.first),
        Dice.Die.Sides.Range.symbol(),
        Integer.to_string(range.last)
      ])
    end
  end
end
