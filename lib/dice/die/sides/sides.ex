defmodule Dice.Die.Sides.Faces do
  defstruct [:number]

  import Dice.Parser.Builder

  defparser do
    unwrap_and_tag(non_negative_integer_literal(), :number)
    |> post_traverse({__MODULE__, :from_parse, []})
  end

  def from_parse(unparsed, parsed, context, _line, _offset) do
    number = Keyword.fetch!(parsed, :number)

    sides = __MODULE__.new(number)

    {unparsed, [sides], context}
  end

  def new(number) when is_integer(number) and number > 0 do
    %__MODULE__{number: number}
  end

  defimpl Dice.Die.Sides do
    def random(%Dice.Die.Sides.Faces{} = sides) do
      :rand.uniform(sides.number)
    end

    def min(%Dice.Die.Sides.Faces{} = _sides) do
      1
    end

    def max(%Dice.Die.Sides.Faces{} = sides) do
      sides.number
    end

    def count(%Dice.Die.Sides.Faces{} = sides) do
      sides.number
    end
  end

  defimpl String.Chars do
    def to_string(%Dice.Die.Sides.Faces{} = sides) do
      Integer.to_string(sides.number)
    end
  end
end
