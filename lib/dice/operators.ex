defmodule Dice.Operators do
  import Dice.Parser.Builder

  defparser do
    choice([
      parsec({Dice.Operators.Addition.Parser, :combinator}),
      parsec({Dice.Operators.Subtraction.Parser, :combinator})
    ])
  end
end
