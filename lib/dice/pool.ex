defmodule Dice.Pool do
  @default_quantity 1

  defstruct [:die, quantity: @default_quantity, modifiers: []]

  import Dice.Parser.Builder

  defparser do
    optional(unwrap_and_tag(non_negative_integer_literal(), :quantity))
    |> concat(unwrap_and_tag(parsec({Dice.Die.Parser, :combinator}), :die))
    |> concat(
      optional(
        repeat(unwrap_and_tag(parsec({Dice.Pool.Modifiers.Parser, :combinator}), :modifier))
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

  defimpl Dice.Expression.Evaluate do
    def evaluate(%Dice.Pool{} = pool) do
      rolls =
        for _ <- 1..pool.quantity do
          Dice.Expression.Evaluate.evaluate(pool.die)
        end

      Enum.reduce(pool.modifiers, rolls, fn modifier, rolls ->
        case modifier do
          %Dice.Pool.Modifiers.Keep{} = modifier ->
            Dice.Pool.Modifiers.Keep.modify(modifier, rolls)

          %Dice.Pool.Modifiers.Drop{} = modifier ->
            Dice.Pool.Modifiers.Drop.modify(modifier, rolls)
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
