defmodule Dice.Pool.Modifiers.Keep do
  defstruct [:number, mode: :random]

  import Dice.Parser.Builder

  defparser do
    modes = [
      high_literal(),
      low_literal(),
      rand_literal()
    ]

    ignore(keep_literal())
    |> concat(optional(unwrap_and_tag(non_negative_integer_literal(), :number)))
    |> concat(optional(unwrap_and_tag(choice(modes), :mode)))
    |> post_traverse({Dice.Pool.Modifiers.Keep, :from_parse, []})
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

  def modify(%__MODULE__{} = keep, rolls) do
    case keep.mode do
      :random -> Enum.take_random(rolls, keep.number)
      :low -> Enum.sort(rolls) |> Enum.take(keep.number)
      :high -> Enum.sort(rolls) |> :lists.reverse() |> Enum.take(keep.number)
    end
  end

  defimpl String.Chars do
    def to_string(%Dice.Pool.Modifiers.Keep{} = keep) do
      "K" <>
        case keep.mode do
          :random -> "#{keep.number}"
          :low -> if keep.number == 1, do: "L", else: "#{keep.number}L"
          :high -> if keep.number == 1, do: "H", else: "#{keep.number}H"
        end
    end
  end
end
