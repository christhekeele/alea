defmodule Dice.Expression do
  defstruct terms: []

  import Dice.Parser.Builder

  defparser do
    optional(whitespace_literal())
    |> concat(unwrap_and_tag(Dice.Term.Parser.maybe_signed_term_combinator(), :term))
    |> concat(
      repeat(
        concat(
          optional(whitespace_literal()),
          unwrap_and_tag(Dice.Term.Parser.signed_term_combinator(), :term)
        )
      )
    )
    |> optional(whitespace_literal())
    |> post_traverse({__MODULE__, :from_parse, []})
  end

  def from_parse(unparsed, parsed, context, _line, _offset) do
    terms = :lists.reverse(Keyword.get_values(parsed, :term))

    expression = %__MODULE__{
      terms: terms
    }

    {unparsed, [expression], context}
  end

  def new(expression) when is_binary(expression) do
    expression |> parse
  end

  def evaluate(%__MODULE__{} = expression) do
    expression.terms
    |> Enum.map(&Dice.Term.evaluate(&1))
    |> Enum.sum()
  end

  def to_string(%__MODULE__{} = expression) do
    expression.terms
    |> Enum.map(&Dice.Term.to_string(&1))
    |> Enum.join()
    |> String.trim_leading("+ ")
    |> String.replace_leading("- ", "-")
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(expression, _opts) do
      [first_term | rest] = expression.terms

      concat(
        List.flatten([
          "#{inspect(__MODULE__)}.new(\"",
          break(""),
          first_term
          |> Dice.Term.to_string()
          |> String.trim_leading("+ ")
          |> String.replace_leading("- ", "-"),
          break(),
          rest
          |> Enum.map(&Dice.Term.to_string(&1))
          |> Enum.intersperse(break()),
          break(""),
          "\")"
        ])
      )
    end
  end
end
