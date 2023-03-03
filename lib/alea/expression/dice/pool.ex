defmodule Alea.Expression.Dice.Pool do
  @default_quantity 1

  defstruct [:die, quantity: @default_quantity, modifiers: []]

  import Alea.Expression.Parser.Builder

  defparser do
    optional(unwrap_and_tag(non_negative_integer_literal(), :quantity))
    |> concat(unwrap_and_tag(parsec({Alea.Expression.Die.Parser, :combinator}), :die))
    |> concat(
      optional(
        repeat(
          unwrap_and_tag(
            parsec({Alea.Expression.Dice.Pool.Modifier.Parser, :combinator}),
            :modifier
          )
        )
      )
    )
    |> post_traverse({__MODULE__, :from_parse, []})
  end

  def from_parse(unparsed, parsed, context, _line, _offset) do
    quantity = Keyword.get(parsed, :quantity, @default_quantity)
    die = Keyword.fetch!(parsed, :die)
    modifiers = parsed |> Keyword.get_values(:modifier) |> :lists.reverse()

    pool = %__MODULE__{
      die: die,
      quantity: quantity,
      modifiers: modifiers
    }

    {unparsed, [pool], context}
  end

  defimpl Alea.Expression.Evaluate do
    def evaluate(%Alea.Expression.Dice.Pool{} = pool) do
      sides =
        case pool.die.sides do
          %Alea.Expression.Die.Sides.Faces{number: number} ->
            Alea.Die.Sides.Faces.new(number)

          %Alea.Expression.Die.Sides.List{options: options} ->
            Alea.Die.Sides.List.new(options)

          %Alea.Expression.Die.Sides.Range{first: first, last: last} ->
            Alea.Die.Sides.Range.new(first, last)
        end

      dice = List.duplicate(%Alea.Die.Types.Normal{sides: sides}, pool.quantity)

      modifiers =
        Enum.map(pool.modifiers, fn
          %Alea.Expression.Dice.Pool.Modifier.Drop{number: number, mode: mode} ->
            Alea.Dice.Pool.Modifier.Drop.new(number, mode)

          %Alea.Expression.Dice.Pool.Modifier.Keep{number: number, mode: mode} ->
            Alea.Dice.Pool.Modifier.Keep.new(number, mode)
        end)

      pool =
        %Alea.Dice.Pool{
          dice: dice,
          modifiers: modifiers
        }
        |> Alea.Dice.Pool.evaluate()

      pool.rolls
      |> Enum.map(& &1.result)
      |> Enum.sum()
    end
  end

  defimpl String.Chars do
    def to_string(%Alea.Expression.Dice.Pool{} = pool) do
      Enum.join(
        [
          if(pool.quantity == 1, do: "", else: Integer.to_string(pool.quantity)),
          Kernel.to_string(pool.die)
        ] ++ Enum.map(pool.modifiers, &Kernel.to_string/1)
      )
    end
  end
end
