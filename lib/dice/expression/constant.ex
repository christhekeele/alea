defmodule Dice.Expression.Constant do
  defstruct [:value]

  def evaluate(%__MODULE__{} = constant) do
    constant.value
  end

  def to_string(%__MODULE__{} = constant) do
    constant.value |> Integer.to_string
  end

  def combinator do
    import NimbleParsec
    import Dice.Expression.Literals

    unwrap_and_tag(non_negative_integer_literal(), :value)
    |> post_traverse({__MODULE__, :combinator_constructor, []})
  end

  def combinator_constructor(rest, args, context, _line, _offset) do
    value = Keyword.fetch!(args, :value)

    constant = %Dice.Expression.Constant{
      value: value
    }

    {rest, [constant], context}
  end
end
