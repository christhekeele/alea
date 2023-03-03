defmodule Dice.Die do
  defstruct [:faces]

  @symbol "d"
  @compile {:inline, symbol: 0}
  def symbol, do: @symbol

  @range_symbol ".."
  @compile {:inline, range_symbol: 0}
  def range_symbol, do: @range_symbol

  import Dice.Parser.Builder

  defparser do
    dice_value_descriptor = non_negative_integer_literal()

    dice_range_descriptor =
      ignore(left_bracket_literal())
      |> concat(unwrap_and_tag(integer_literal(), :first))
      |> concat(ignore(string(@range_symbol)))
      |> concat(unwrap_and_tag(integer_literal(), :last))
      |> concat(right_bracket_literal())
      |> post_traverse({__MODULE__, :dice_range_constructor, []})

    dice_set_descriptor =
      ignore(left_brace_literal())
      |> concat(unwrap_and_tag(integer_literal(), :number))
      |> repeat(concat(ignore(comma_literal()), unwrap_and_tag(integer_literal(), :number)))
      |> concat(ignore(right_brace_literal()))
      |> post_traverse({__MODULE__, :dice_set_constructor, []})

    numeric_dice_descriptor = [
      dice_value_descriptor,
      dice_range_descriptor,
      dice_set_descriptor
    ]

    concat(ignore(string(@symbol)), unwrap_and_tag(choice(numeric_dice_descriptor), :faces))
    |> post_traverse({__MODULE__, :from_parse, []})
  end

  def from_parse(unparsed, parsed, context, _line, _offset) do
    faces = Keyword.fetch!(parsed, :faces)

    die = %__MODULE__{faces: faces}

    {unparsed, [die], context}
  end

  def dice_range_constructor(unparsed, parsed, context, _line, _offset) do
    first = Keyword.fetch!(parsed, :first)
    last = Keyword.fetch!(parsed, :last)

    {unparsed, [Range.new(first, last)], context}
  end

  def dice_set_constructor(unparsed, parsed, context, _line, _offset) do
    numbers = Keyword.get_values(parsed, :number) |> :lists.reverse()

    {unparsed, [numbers], context}
  end

  defimpl Dice.Expression.Evaluate do
    def evaluate(%Dice.Die{} = die) do
      case die.faces do
        number when is_integer(number) and number > 0 -> :rand.uniform(number)
        %Range{} = range -> Enum.random(range)
        faces when is_list(faces) -> Enum.random(faces)
      end
    end
  end

  defimpl String.Chars do
    def to_string(%Dice.Die{} = die) do
      Dice.Die.symbol() <> case die.faces do
        number when is_integer(number) -> Integer.to_string(number)
        %Range{} = range -> Enum.join([Integer.to_string(range.first), Dice.Die.range_symbol(), Integer.to_string(range.last)])
        faces when is_list(faces) -> Enum.join(faces |> Enum.map(&Integer.to_string/1), ", ")
      end
    end
  end
end
