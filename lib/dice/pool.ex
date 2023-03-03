defmodule Dice.Pool do
  defstruct [:die, quantity: 1, modifiers: []]

  import Dice.Parser.Builder

  defparser do
    numeric_dice_modifiers = [
      __MODULE__.Modifier.Drop.Parser.combinator(),
      __MODULE__.Modifier.Keep.Parser.combinator()
    ]

    optional(unwrap_and_tag(non_negative_integer_literal(), :quantity))
    |> concat(unwrap_and_tag(Dice.Die.Parser.combinator(), :die))
    |> concat(optional(repeat(unwrap_and_tag(choice(numeric_dice_modifiers), :modifier))))
    |> post_traverse({__MODULE__, :from_parse, []})
  end

  def from_parse(unparsed, parsed, context, _line, _offset) do
    quantity = Keyword.get(parsed, :quantity, 1)
    die = Keyword.fetch!(parsed, :die)
    modifiers = :lists.reverse(Keyword.get_values(parsed, :modifier))

    roll = %__MODULE__{
      die: die,
      quantity: quantity,
      modifiers: modifiers
    }

    {unparsed, [roll], context}
  end

  def evaluate(%__MODULE__{} = roll) do
    rolls =
      for _ <- 1..roll.quantity do
        Dice.Die.roll(roll.die)
      end

    Enum.reduce(roll.modifiers, rolls, fn modifier, rolls ->
      case modifier do
        %Dice.Pool.Modifier.Keep{} = modifier -> Dice.Pool.Modifier.Keep.modify(modifier, rolls)
        %Dice.Pool.Modifier.Drop{} = modifier -> Dice.Pool.Modifier.Drop.modify(modifier, rolls)
      end
    end)
    |> Enum.sum()
  end

  def to_string(%__MODULE__{} = roll) do
    Enum.join(
      [
        if(roll.quantity == 1, do: "", else: Integer.to_string(roll.quantity)),
        Dice.Die.to_string(roll.die)
      ] ++
        Enum.map(roll.modifiers, fn modifier ->
          case modifier do
            %Dice.Pool.Modifier.Keep{} = modifier -> Dice.Pool.Modifier.Keep.to_string(modifier)
            %Dice.Pool.Modifier.Drop{} = modifier -> Dice.Pool.Modifier.Drop.to_string(modifier)
          end
        end)
    )
  end
end
