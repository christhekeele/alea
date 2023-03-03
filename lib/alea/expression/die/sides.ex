defmodule Alea.Expression.Die.Sides do
  import Alea.Expression.Parser.Builder

  defparser do
    choice([
      parsec({Alea.Expression.Die.Sides.Faces.Parser, :combinator}),
      parsec({Alea.Expression.Die.Sides.Range.Parser, :combinator}),
      parsec({Alea.Expression.Die.Sides.List.Parser, :combinator})
    ])
  end
end
