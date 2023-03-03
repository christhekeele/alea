defmodule Alea.Expression.Operators do
  import Alea.Expression.Parser.Builder

  defparser do
    choice([
      parsec({Alea.Expression.Operators.Addition.Parser, :combinator}),
      parsec({Alea.Expression.Operators.Subtraction.Parser, :combinator})
    ])
  end
end
