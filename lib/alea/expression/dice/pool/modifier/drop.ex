defmodule Alea.Expression.Dice.Pool.Modifier.Drop do
  defstruct [:number, mode: :random]

  @symbol "D"

  @symbol_mode_high "H"
  @symbol_mode_low "L"
  @symbol_mode_random "R"

  @symbol_mode_default @symbol_mode_random

  import Alea.Expression.Parser.Builder

  defparser do
    modes = [
      string(@symbol_mode_high),
      string(@symbol_mode_low),
      string(@symbol_mode_random)
    ]

    ignore(string(@symbol))
    |> concat(optional(unwrap_and_tag(non_negative_integer_literal(), :number)))
    |> concat(optional(unwrap_and_tag(choice(modes), :mode)))
    |> post_traverse({__MODULE__, :from_parse, []})
  end

  def from_parse(unparsed, parsed, context, _line, _offset) do
    number = Keyword.get(parsed, :number, 1)

    mode =
      case Keyword.get(parsed, :mode, @symbol_mode_default) do
        @symbol_mode_high -> :high
        @symbol_mode_low -> :low
        @symbol_mode_random -> :random
      end

    modifier = %__MODULE__{
      number: number,
      mode: mode
    }

    {unparsed, [modifier], context}
  end

  def to_string(%Alea.Expression.Dice.Pool.Modifier.Drop{} = drop) do
    @symbol <>
      case drop.mode do
        :random ->
          "#{drop.number}"

        :low ->
          if drop.number == 1, do: @symbol_mode_low, else: "#{drop.number}#{@symbol_mode_low}"

        :high ->
          if drop.number == 1, do: @symbol_mode_random, else: "#{drop.number}#{@symbol_mode_high}"
      end
  end

  defimpl String.Chars do
    def to_string(%Alea.Expression.Dice.Pool.Modifier.Drop{} = drop) do
      Alea.Expression.Dice.Pool.Modifier.Drop.to_string(drop)
    end
  end
end
