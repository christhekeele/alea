defmodule Alea.Dice.Pool.Modifier.Keep do
  defstruct [:number, mode: :random]

  def new(number, mode) do
    %__MODULE__{
      number: number,
      mode: mode
    }
  end

  def rolls(%__MODULE__{} = keep, rolls) do
    case keep.mode do
      :random -> Enum.take_random(rolls, keep.number)
      :low -> Enum.sort_by(rolls, & &1.result) |> Enum.take(keep.number)
      :high -> Enum.sort_by(rolls, & &1.result) |> Enum.take(-keep.number)
    end
  end

  defimpl Alea.Dice.Pool.Modifier do
    def apply(%Alea.Dice.Pool.Modifier.Keep{} = keep, pool) do
      pool = Alea.Dice.Pool.roll_all(pool)
      %Alea.Dice.Pool{pool | rolls: Alea.Dice.Pool.Modifier.Keep.rolls(keep, pool.rolls)}
    end
  end
end
