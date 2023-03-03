defmodule Alea.Expression do
  defstruct [:expression]

  import Alea.Expression.Parser.Builder

  defparser do
    expression = [
      parsec({Alea.Expression.Operators.Parser, :combinator}),
      parsec({Alea.Expression.Term.Parser, :combinator})
    ]

    optional(whitespace_literal())
    |> unwrap_and_tag(choice(expression), :expression)
    |> optional(whitespace_literal())
    |> post_traverse({__MODULE__, :from_parse, []})
  end

  def from_parse(unparsed, parsed, context, _line, _offset) do
    expression = Keyword.fetch!(parsed, :expression)

    expression = %__MODULE__{
      expression: expression
    }

    {unparsed, [expression], context}
  end

  defimpl Alea.Expression.Evaluate do
    def evaluate(%Alea.Expression{} = expression) do
      Alea.Expression.Evaluate.evaluate(expression.expression)
    end
  end

  defimpl String.Chars do
    def to_string(%Alea.Expression{} = expression) do
      Kernel.to_string(expression.expression)
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%Alea.Expression{} = expression, _opts) do
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
