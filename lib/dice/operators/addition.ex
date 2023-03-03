defmodule Dice.Operator.Addition do
  defstruct [:left, :right]

  import Dice.Parser.Builder

  defparser do
    unwrap_and_tag(parsec({Dice.Expression.Term.Parser, :combinator}), :left)
    |> concat(optional(whitespace_literal()))
    |> concat(ignore(positive_literal()))
    |> concat(optional(whitespace_literal()))
    |> unwrap_and_tag(parsec({Dice.Expression.Term.Parser, :combinator}), :right)
    |> post_traverse({__MODULE__, :from_parse, []})
  end

  def from_parse(unparsed, parsed, context, _line, _offset) do
    left = Keyword.fetch!(parsed, :left)
    right = Keyword.fetch!(parsed, :right)

    addition = %__MODULE__{
      left: left,
      right: right
    }

    {unparsed, [addition], context}
  end

  defimpl Dice.Expression.Evaluate do
    def evaluate(%Dice.Operator.Addition{} = addition) do
      Dice.Expression.Evaluate.evaluate(addition.left) + Dice.Expression.Evaluate.evaluate(addition.right)
    end
  end

  defimpl String.Chars do
    def to_string(%Dice.Operator.Addition{} = addition) do
      Enum.join([
        Kernel.to_string(addition.left),
        "+",
        Kernel.to_string(addition.right)
      ], " ")
    end
  end
end
