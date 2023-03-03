defmodule Dice.Operator.Subtraction do
  defstruct [:left, :right]

  @symbol "-"
  @compile {:inline, symbol: 0}
  def symbol, do: @symbol

  import Dice.Parser.Builder

  defparser do
    unwrap_and_tag(parsec({Dice.Expression.Term.Parser, :combinator}), :left)
    |> concat(optional(whitespace_literal()))
    |> concat(ignore(string(@symbol)))
    |> concat(optional(whitespace_literal()))
    |> unwrap_and_tag(parsec({Dice.Expression.Term.Parser, :combinator}), :right)
    |> post_traverse({__MODULE__, :from_parse, []})
  end

  def from_parse(unparsed, parsed, context, _line, _offset) do
    left = Keyword.fetch!(parsed, :left)
    right = Keyword.fetch!(parsed, :right)

    subtraction = %__MODULE__{
      left: left,
      right: right
    }

    {unparsed, [subtraction], context}
  end

  defimpl Dice.Expression.Evaluate do
    def evaluate(%Dice.Operator.Subtraction{} = subtraction) do
      Dice.Expression.Evaluate.evaluate(subtraction.left) - Dice.Expression.Evaluate.evaluate(subtraction.right)
    end
  end

  defimpl String.Chars do
    def to_string(%Dice.Operator.Subtraction{} = subtraction) do
      Enum.join([
        Kernel.to_string(subtraction.left),
        Dice.Operator.Subtraction.symbol(),
        Kernel.to_string(subtraction.right)
      ], " ")
    end
  end
end
