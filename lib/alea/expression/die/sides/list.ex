defmodule Alea.Expression.Die.Sides.List do
  defstruct [:options]

  import Alea.Expression.Parser.Builder

  defparser do
    ignore(left_brace_literal())
    |> concat(unwrap_and_tag(integer_literal(), :number))
    |> repeat(concat(ignore(comma_literal()), unwrap_and_tag(integer_literal(), :number)))
    |> concat(ignore(right_brace_literal()))
    |> post_traverse({__MODULE__, :from_parse, []})
  end

  def from_parse(unparsed, parsed, context, _line, _offset) do
    options = parsed |> Keyword.get_values(:number) |> :lists.reverse()

    list = %__MODULE__{options: options}

    {unparsed, [list], context}
  end

  defimpl String.Chars do
    def to_string(%Alea.Expression.Die.Sides.List{} = list) do
      Enum.join(list.options |> Enum.map(&Integer.to_string/1), ", ")
    end
  end
end
