defprotocol Dice.Expression.Evaluate do
  def evaluate(node)
end

defmodule Dice.Expression.Term do
  import Dice.Parser.Builder

  defparser do
    choice([
      parsec({Dice.Pool.Parser, :combinator}),
      parsec({Dice.Constant.Parser, :combinator}),
    ])
  end

end

defmodule Dice.Expression.Operation do
  import Dice.Parser.Builder

  defparser do
    choice([
      parsec({Dice.Operator.Addition.Parser, :combinator}),
      parsec({Dice.Operator.Subtraction.Parser, :combinator}),
    ])
  end

end

defmodule Dice.Expression do
  defstruct [:expression]

  import Dice.Parser.Builder

  defparser do

    expression = [
      parsec({Dice.Expression.Operation.Parser, :combinator}),
      parsec({Dice.Expression.Term.Parser, :combinator}),
    ]

    optional(whitespace_literal())
    |> unwrap_and_tag(choice(expression), :expression)
    |> optional(whitespace_literal())
    |> post_traverse({__MODULE__, :from_parse, []})
  end

  # import NimbleParsec
  # defparsec :parse, parsec({__MODULE__.Parser, :parse})

  def from_parse(unparsed, parsed, context, _line, _offset) do
    expression = Keyword.fetch!(parsed, :expression)

    expression = %__MODULE__{
      expression: expression
    }

    {unparsed, [expression], context}
  end

  defimpl Dice.Expression.Evaluate do
    def evaluate(%Dice.Expression{} = expression) do
      Dice.Expression.Evaluate.evaluate(expression.expression)
    end
  end

  defimpl String.Chars do
    def to_string(%Dice.Expression{} = expression) do
      Kernel.to_string(expression.expression)
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%Dice.Expression{} = expression, _opts) do
      concat([
        "#{inspect(__impl__(:for))}.new(\"",
        break(""),
        Kernel.to_string(expression.expression),
        break(""),
        "\")"
      ])
    end
  end
end
