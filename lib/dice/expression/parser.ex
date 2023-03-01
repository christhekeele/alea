defmodule Dice.Expression.Parser do
  import NimbleParsec

  expression_parser = unwrap_and_tag(Dice.Expression.combinator(), :expression) |> eos()

  defparsec(:parse, expression_parser, export_metadata: true)
end
