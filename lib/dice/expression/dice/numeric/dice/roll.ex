defmodule Dice.Expression.Dice.Numeric.Dice.Roll do
  defstruct [:dice, number: 1, modifiers: []]

  def evaluate(%__MODULE__{} = roll) do
    rolls = for _ <- 1..roll.number do
      Dice.Expression.Dice.Numeric.Dice.roll(roll.dice)
    end

    Enum.reduce(roll.modifiers, rolls, fn modifier, rolls ->
      case modifier do
        %Dice.Expression.Dice.Numeric.Dice.Roll.Modifier.Keep{} = modifier -> Dice.Expression.Dice.Numeric.Dice.Roll.Modifier.Keep.modify(modifier, rolls)
        %Dice.Expression.Dice.Numeric.Dice.Roll.Modifier.Drop{} = modifier -> Dice.Expression.Dice.Numeric.Dice.Roll.Modifier.Drop.modify(modifier, rolls)
      end
    end)
    |> Enum.sum
  end

  def to_string(%__MODULE__{} = roll) do
    Enum.join([
      (if roll.number == 1, do: "", else: Integer.to_string(roll.number)),
      Dice.Expression.Dice.Numeric.Dice.to_string(roll.dice)
    ] ++ Enum.map(roll.modifiers, fn modifier ->
      case modifier do
        %Dice.Expression.Dice.Numeric.Dice.Roll.Modifier.Keep{} = modifier -> Dice.Expression.Dice.Numeric.Dice.Roll.Modifier.Keep.to_string(modifier)
        %Dice.Expression.Dice.Numeric.Dice.Roll.Modifier.Drop{} = modifier -> Dice.Expression.Dice.Numeric.Dice.Roll.Modifier.Drop.to_string(modifier)
      end
    end))
  end

  def combinator do
    import NimbleParsec
    import Dice.Expression.Literals

    numeric_dice_modifiers = [
      Dice.Expression.Dice.Numeric.Dice.Roll.Modifier.Keep.combinator(),
      Dice.Expression.Dice.Numeric.Dice.Roll.Modifier.Drop.combinator()
    ]

    optional(unwrap_and_tag(non_negative_integer_literal(), :number))
    |> concat(unwrap_and_tag(Dice.Expression.Dice.Numeric.Dice.combinator(), :dice))
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
