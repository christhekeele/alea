defmodule Dice.Expression do
  defstruct [terms: []]

  def new(expression) when is_binary(expression) do
    expression |> parse
  end

  def roll(expression) when is_binary(expression) do
    expression |> new |> evaluate
  end

  def generate do
    {__MODULE__.Parser, :parse}
    |> NimbleParsec.parsec
    |> NimbleParsec.generate
    |> parse
  end

  def evaluate(%__MODULE__{} = expression) do
    expression.terms
    |> Enum.map(&Dice.Expression.Term.evaluate(&1))
    |> Enum.sum
  end

  def to_string(%__MODULE__{} = expression) do
    expression.terms
    |> Enum.map(&Dice.Expression.Term.to_string(&1))
    |> Enum.join
    |> String.trim_leading("+ ")
    |> String.replace_leading("- ", "-")
  end

  def parse(input) when is_binary(input) do
    {:ok, [expression: expression], _unparsed, _context, _line, _offset} = __MODULE__.Parser.parse(input)

    expression
  end

  def combinator do
    import NimbleParsec
    import Dice.Expression.Literals

    optional(whitespace_literal())
    |> concat(unwrap_and_tag(Dice.Expression.Term.maybe_signed_term_combinator(), :term))
    |> concat(repeat(concat(optional(whitespace_literal()), unwrap_and_tag(Dice.Expression.Term.signed_term_combinator(), :term))))
    |> optional(whitespace_literal())
    |> post_traverse({__MODULE__, :combinator_constructor, []})
  end

  def combinator_constructor(rest, args, context, _line, _offset) do
    terms = :lists.reverse(Keyword.get_values(args, :term))

    expression = %Dice.Expression{
      terms: terms
    }

    {rest, [expression], context}
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(expression, _opts) do
      [first_term | rest] = expression.terms

      concat(List.flatten([
        "Dice.Expression.new(\"",
        break(""),
        first_term
        |> Dice.Expression.Term.to_string
        |> String.trim_leading("+ ")
        |> String.replace_leading("- ", "-"),
        break(),
        rest
        |> Enum.map(&Dice.Expression.Term.to_string(&1))
        |> Enum.intersperse(break()),
        break(""),
        "\")"
      ]))
    end
  end
end
