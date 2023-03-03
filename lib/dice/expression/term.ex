defmodule Dice.Expression.Term do
  import Dice.Parser.Builder

  defparser do
    choice([
      parsec({Dice.Pool.Parser, :combinator}),
      parsec({Dice.Constant.Parser, :combinator})
    ])
  end
end
