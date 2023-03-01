defmodule Dice.Expression.Dice.Numeric.Dice.Roll.Modifier.Keep do
  defstruct [:number, mode: :random]

  def modify(%__MODULE__{} = keep, rolls) do
    case keep.mode do
      :random -> Enum.take_random(rolls, keep.number)
      :low -> Enum.sort(rolls) |> Enum.take(keep.number)
      :high -> Enum.sort(rolls) |> :lists.reverse |> Enum.take(keep.number)
    end
  end

  def to_string(%__MODULE__{} = keep) do
    "K" <> case keep.mode do
      :random -> "#{keep.number}"
      :low -> if keep.number == 1, do: "L", else: "#{keep.number}L"
      :high -> if keep.number == 1, do: "H", else: "#{keep.number}H"
    end
  end

  def combinator do
    import NimbleParsec
    import Dice.Expression.Literals

    modes = [
      high_literal(),
      low_literal(),
      rand_literal()
    ]

    ignore(keep_literal())
    |> concat(optional(unwrap_and_tag(non_negative_integer_literal(), :number)))
    |> concat(optional(unwrap_and_tag(choice(modes), :mode)))
    |> post_traverse({__MODULE__, :combinator_constructor, []})
  end

  def combinator_constructor(rest, args, context, _line, _offset) do
    number = Keyword.get(args, :number, 1)
    mode = case Keyword.get(args, :mode, "R") do
      "H" -> :high
      "L" -> :low
      "R" -> :random
    end

    modifier = %__MODULE__{
      number: number,
      mode: mode
    }

    {rest, [modifier], context}
  end
end
