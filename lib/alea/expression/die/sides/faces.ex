defmodule Alea.Expression.Die.Sides.Faces do
  defstruct [:number]

  import Alea.Expression.Parser.Builder

  defparser do
    unwrap_and_tag(non_negative_integer_literal(), :number)
    |> post_traverse({__MODULE__, :from_parse, []})
  end

  def from_parse(unparsed, parsed, context, _line, _offset) do
    number = Keyword.fetch!(parsed, :number)

    sides = %__MODULE__{number: number}

    {unparsed, [sides], context}
  end

  defimpl String.Chars do
    def to_string(%Alea.Expression.Die.Sides.Faces{} = sides) do
      Integer.to_string(sides.number)
    end
  end
end
