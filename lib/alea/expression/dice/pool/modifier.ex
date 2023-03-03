defmodule Alea.Expression.Dice.Pool.Modifier do
  import Alea.Expression.Parser.Builder

  defparser do
    choice([
      parsec({Alea.Expression.Dice.Pool.Modifier.Drop.Parser, :combinator}),
      parsec({Alea.Expression.Dice.Pool.Modifier.Keep.Parser, :combinator})
    ])
  end
end
