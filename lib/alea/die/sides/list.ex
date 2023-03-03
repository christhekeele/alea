defmodule Alea.Die.Sides.List do
  defstruct [:options]

  def new(options) when is_list(options) do
    %__MODULE__{options: Enum.sort(options)}
  end

  defimpl Alea.Die.Sides do
    def random(%Alea.Die.Sides.List{} = list) do
      list.options |> Enum.random()
    end

    def min(%Alea.Die.Sides.List{} = list) do
      list.options |> List.first()
    end

    def max(%Alea.Die.Sides.List{} = list) do
      list.options |> List.last()
    end

    def count(%Alea.Die.Sides.List{} = list) do
      list.options |> length
    end
  end
end
