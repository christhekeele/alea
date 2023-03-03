defmodule Alea.Die.Sides.Range do
  defstruct [:first, :last]

  def new(first, last) when is_integer(first) and is_integer(last) do
    if first < last do
      %__MODULE__{first: first, last: last}
    else
      %__MODULE__{first: last, last: first}
    end
  end

  defimpl Alea.Die.Sides do
    def random(%Alea.Die.Sides.Range{} = range) do
      Range.new(range.first, range.last) |> Enum.random()
    end

    def min(%Alea.Die.Sides.Range{} = range) do
      range.first
    end

    def max(%Alea.Die.Sides.Range{} = range) do
      range.last
    end

    def count(%Alea.Die.Sides.Range{} = range) do
      range.first - range.last + 1
    end
  end
end
