defmodule Dice.Expression.Literals do
  import NimbleParsec

  def whitespace_literal, do: ignore(times(choice([string(" "), string("\n")]), min: 1))
  def non_negative_integer_literal, do: integer(min: 1)
  def integer_literal, do: optional(unwrap_and_tag(negative_literal(), :negative))
    |> concat(unwrap_and_tag(non_negative_integer_literal(), :number))
    |> post_traverse({__MODULE__, :integer_literal_constructor, []})

  def negative_literal, do: string("-")
  def positive_literal, do: string("+")

  def dice_literal, do: string("d")

  def range_literal, do: string("..")
  def comma_literal, do: concat(optional(whitespace_literal()), concat(string(","), optional(whitespace_literal())))
  def left_paren_literal, do: string("(")
  def right_paren_literal, do: string(")")
  def left_brace_literal, do: string("{")
  def right_brace_literal, do: string("}")
  def left_bracket_literal, do: string("[")
  def right_bracket_literal, do: string("]")

  def keep_literal, do: string("K")
  def drop_literal, do: string("D")

  def high_literal, do: string("H")
  def low_literal,  do: string("L")
  def rand_literal, do: string("R")

  def integer_literal_constructor(rest, args, context, _line, _offset) do
    number = Keyword.fetch!(args, :number)
    number = if Keyword.get(args, :negative), do: -1 * number, else: number

    {rest, [number], context}
  end
end
