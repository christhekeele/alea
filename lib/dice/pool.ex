defmodule Dice.Pool do
  defstruct [:dice, number: 1, modifiers: []]

  def evaluate(%__MODULE__{} = roll) do
    rolls = for _ <- 1..roll.number do
      Dice.roll(roll.dice)
    end

    Enum.reduce(roll.modifiers, rolls, fn modifier, rolls ->
      case modifier do
        %Dice.Pool.Modifier.Keep{} = modifier -> Dice.Pool.Modifier.Keep.modify(modifier, rolls)
        %Dice.Pool.Modifier.Drop{} = modifier -> Dice.Pool.Modifier.Drop.modify(modifier, rolls)
      end
    end)
    |> Enum.sum
  end

  def to_string(%__MODULE__{} = roll) do
    Enum.join([
      (if roll.number == 1, do: "", else: Integer.to_string(roll.number)),
      Dice.to_string(roll.dice)
    ] ++ Enum.map(roll.modifiers, fn modifier ->
      case modifier do
        %Dice.Pool.Modifier.Keep{} = modifier -> Dice.Pool.Modifier.Keep.to_string(modifier)
        %Dice.Pool.Modifier.Drop{} = modifier -> Dice.Pool.Modifier.Drop.to_string(modifier)
      end
    end))
  end

  def combinator do
    import NimbleParsec
    import Dice.Expression.Literals

    numeric_dice_modifiers = [
      Dice.Pool.Modifier.Keep.combinator(),
      Dice.Pool.Modifier.Drop.combinator()
    ]

    optional(unwrap_and_tag(non_negative_integer_literal(), :number))
    |> concat(unwrap_and_tag(Dice.combinator(), :dice))
    |> concat(optional(repeat(unwrap_and_tag(choice(numeric_dice_modifiers), :modifier))))
    |> post_traverse({__MODULE__, :combinator_constructor, []})
  end

  def combinator_constructor(rest, args, context, _line, _offset) do
    number = Keyword.get(args, :number, 1)
    dice = Keyword.fetch!(args, :dice)
    modifiers = :lists.reverse(Keyword.get_values(args, :modifier))

    roll = %__MODULE__{
      dice: dice,
      number: number,
      modifiers: modifiers
    }

    {rest, [roll], context}
  end
end
