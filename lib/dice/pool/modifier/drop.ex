defmodule Dice.Pool.Modifier.Drop do
  defstruct [:number, mode: :random]

  import Dice.Parser.Builder

  defparser do
    modes = [
      high_literal(),
      low_literal(),
      rand_literal()
    ]

    ignore(drop_literal())
    |> concat(optional(unwrap_and_tag(non_negative_integer_literal(), :number)))
    |> concat(optional(unwrap_and_tag(choice(modes), :mode)))
    |> post_traverse({Dice.Pool.Modifier.Drop, :from_parse, []})
  end

  def from_parse(unparsed, parsed, context, _line, _offset) do
    number = Keyword.get(parsed, :number, 1)

    mode =
      case Keyword.get(parsed, :mode, "R") do
        "H" -> :high
        "L" -> :low
        "R" -> :random
      end

    modifier = %__MODULE__{
      number: number,
      mode: mode
    }

    {unparsed, [modifier], context}
  end

  def modify(%__MODULE__{} = drop, rolls) do
    case drop.mode do
      :random -> Enum.take_random(rolls, length(rolls) - drop.number)
      :low -> Enum.sort(rolls) |> Enum.drop(drop.number)
      :high -> Enum.sort(rolls) |> :lists.reverse() |> Enum.drop(drop.number)
    end
  end

  def to_string(%__MODULE__{} = drop) do
    "D" <>
      case drop.mode do
        :random -> "#{drop.number}"
        :low -> if drop.number == 1, do: "L", else: "#{drop.number}L"
        :high -> if drop.number == 1, do: "H", else: "#{drop.number}H"
      end
  end
end
