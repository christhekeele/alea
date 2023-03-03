defmodule Dice.Constant do
  defstruct [:value]

  import Dice.Parser.Builder

  defparser do
    non_negative_integer_literal()
    |> unwrap_and_tag(:value)
    |> post_traverse({__MODULE__, :from_parse, []})
  end

  def from_parse(unparsed, parsed, context, _line, _offset) do
    value = Keyword.fetch!(parsed, :value)

    constant = %__MODULE__{
      value: value
    }

    {unparsed, [constant], context}
  end

  def evaluate(%__MODULE__{} = constant) do
    constant.value
  end

  def to_string(%__MODULE__{} = constant) do
    constant.value |> Integer.to_string()
  end
end
