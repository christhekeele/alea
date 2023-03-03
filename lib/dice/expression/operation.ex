defmodule Dice.Expression.Operation do
  import Dice.Parser.Builder

  defparser do
    choice([
      parsec({Dice.Operator.Addition.Parser, :combinator}),
      parsec({Dice.Operator.Subtraction.Parser, :combinator})
    ])
  end

end
