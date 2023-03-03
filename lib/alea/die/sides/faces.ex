defmodule Alea.Die.Sides.Faces do
  defstruct [:number]

  def new(number) when is_integer(number) and number > 0 do
    %__MODULE__{number: number}
  end

  defimpl Alea.Die.Sides do
    def random(%Alea.Die.Sides.Faces{} = sides) do
      :rand.uniform(sides.number)
    end

    def min(%Alea.Die.Sides.Faces{} = _sides) do
      1
    end

    def max(%Alea.Die.Sides.Faces{} = sides) do
      sides.number
    end

    def count(%Alea.Die.Sides.Faces{} = sides) do
      sides.number
    end
  end
end
