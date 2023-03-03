defmodule Alea.Expression.Parser.Helpers do
  import NimbleParsec

  def whitespace_literal, do: ignore(times(choice([string(" "), string("\n")]), min: 1))
  def non_negative_integer_literal, do: integer(min: 1)

  def integer_literal,
    do:
      optional(unwrap_and_tag(string("-"), :negative))
      |> concat(unwrap_and_tag(non_negative_integer_literal(), :number))
      |> post_traverse({__MODULE__, :integer_literal_constructor, []})

  def integer_literal_constructor(rest, args, context, _line, _offset) do
    number = Keyword.fetch!(args, :number)
    number = if Keyword.get(args, :negative), do: -1 * number, else: number

    {rest, [number], context}
  end

  def comma_literal,
    do:
      optional(whitespace_literal())
      |> concat(string(","))
      |> concat(optional(whitespace_literal()))

  def left_paren_literal, do: string("(")
  def right_paren_literal, do: string(")")
  def left_brace_literal, do: string("{")
  def right_brace_literal, do: string("}")
  def left_bracket_literal, do: string("[")
  def right_bracket_literal, do: string("]")
end
