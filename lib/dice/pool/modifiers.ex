defmodule Dice.Pool.Modifiers do
  import Dice.Parser.Builder

  defparser do
    choice([
      parsec({Dice.Pool.Modifiers.Drop.Parser, :combinator}),
      parsec({Dice.Pool.Modifiers.Keep.Parser, :combinator})
    ])
  end
end
