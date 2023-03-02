defmodule Dice.Pool.Modifier.Drop do
  defstruct [:number, mode: :random]

  def modify(%__MODULE__{} = drop, rolls) do
    case drop.mode do
      :random -> Enum.take_random(rolls, length(rolls) - drop.number)
      :low -> Enum.sort(rolls) |> Enum.drop(drop.number)
      :high -> Enum.sort(rolls) |> :lists.reverse |> Enum.drop(drop.number)
    end
  end

  def to_string(%__MODULE__{} = drop) do
    "D" <> case drop.mode do
      :random -> "#{drop.number}"
      :low -> if drop.number == 1, do: "L", else: "#{drop.number}L"
      :high -> if drop.number == 1, do: "H", else: "#{drop.number}H"
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

    ignore(drop_literal())
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
