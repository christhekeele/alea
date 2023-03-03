defmodule Dice.Die.Sides.List do
  defstruct [:options]

  import Dice.Parser.Builder

  defparser do
    ignore(left_brace_literal())
    |> concat(unwrap_and_tag(integer_literal(), :number))
    |> repeat(concat(ignore(comma_literal()), unwrap_and_tag(integer_literal(), :number)))
    |> concat(ignore(right_brace_literal()))
    |> post_traverse({__MODULE__, :from_parse, []})
  end

  def from_parse(unparsed, parsed, context, _line, _offset) do
    options = Keyword.get_values(parsed, :number) |> :lists.reverse()

    list = __MODULE__.new(options)

    {unparsed, [list], context}
  end

  def new(options) when is_list(options) do
    %__MODULE__{options: Enum.sort(options)}
  end

  defimpl Dice.Die.Sides do
    def random(%Dice.Die.Sides.List{} = list) do
      list.options |> Enum.random()
    end

    def min(%Dice.Die.Sides.List{} = list) do
      list.options |> List.first()
    end

    def max(%Dice.Die.Sides.List{} = list) do
      list.options |> List.last()
    end

    def count(%Dice.Die.Sides.List{} = list) do
      list.options |> length
    end
  end

  defimpl String.Chars do
    def to_string(%Dice.Die.Sides.List{} = list) do
      Enum.join(list.options |> Enum.map(&Integer.to_string/1), ", ")
    end
  end
end
