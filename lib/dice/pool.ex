defmodule Dice.Pool do
  defstruct [:die, quantity: 1, modifiers: []]

  import Dice.Parser.Builder

  defparser do
    numeric_dice_modifiers = [
      parsec({__MODULE__.Modifier.Drop.Parser, :combinator}),
      parsec({__MODULE__.Modifier.Keep.Parser, :combinator})
    ]

    optional(unwrap_and_tag(non_negative_integer_literal(), :quantity))
    |> concat(unwrap_and_tag(parsec({Dice.Die.Parser, :combinator}), :die))
    |> concat(optional(repeat(unwrap_and_tag(choice(numeric_dice_modifiers), :modifier))))
    |> post_traverse({__MODULE__, :from_parse, []})
  end

  def from_parse(unparsed, parsed, context, _line, _offset) do
    quantity = Keyword.get(parsed, :quantity, 1)
    die = Keyword.fetch!(parsed, :die)
    modifiers = :lists.reverse(Keyword.get_values(parsed, :modifier))

    pool = %__MODULE__{
      die: die,
      quantity: quantity,
      modifiers: modifiers
    }

    {unparsed, [pool], context}
  end

  defimpl Dice.Expression.Evaluate do
    def evaluate(%Dice.Pool{} = pool) do
      rolls =
        for _ <- 1..pool.quantity do
          Dice.Expression.Evaluate.evaluate(pool.die)
        end

      Enum.reduce(pool.modifiers, rolls, fn modifier, rolls ->
        case modifier do
          %Dice.Pool.Modifier.Keep{} = modifier -> Dice.Pool.Modifier.Keep.modify(modifier, rolls)
          %Dice.Pool.Modifier.Drop{} = modifier -> Dice.Pool.Modifier.Drop.modify(modifier, rolls)
        end
      end)
      |> Enum.sum()
    end
  end

  defimpl String.Chars do
    def to_string(%Dice.Pool{} = pool) do
      Enum.join(
        [
          if(pool.quantity == 1, do: "", else: Integer.to_string(pool.quantity)),
          Kernel.to_string(pool.die)
        ] ++ Enum.map(pool.modifiers, &Kernel.to_string/1)
      )
    end
  end
end
