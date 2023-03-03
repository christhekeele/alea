defmodule Alea.Expression.Term do
  import Alea.Expression.Parser.Builder

  defparser do
    choice([
      parsec({Alea.Expression.Dice.Pool.Parser, :combinator}),
      parsec({Alea.Expression.Constant.Parser, :combinator})
    ])
  end
end
