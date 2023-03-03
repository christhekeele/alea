defmodule Alea.Die.Types.Normal do
  defstruct [:sides]

  defimpl Alea.Die.Roll do
    def roll(%Alea.Die.Types.Normal{} = die) do
      %Alea.Die.Roll{
        die: die,
        result: Alea.Die.Sides.random(die.sides)
      }
    end
  end
end
