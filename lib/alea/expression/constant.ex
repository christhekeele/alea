defmodule Alea.Expression.Constant do
  defstruct [:value]

  import Alea.Expression.Parser.Builder

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

  defimpl Alea.Expression.Evaluate do
    def evaluate(%Alea.Expression.Constant{} = constant) do
      constant.value
    end
  end

  defimpl String.Chars do
    def to_string(%Alea.Expression.Constant{} = constant) do
      Kernel.to_string(constant.value)
    end
  end
end
