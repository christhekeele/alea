defmodule Alea.Dice.Pool.Modifier.Drop do
  defstruct [:number, mode: :random]

  def new(number, mode) do
    %__MODULE__{
      number: number,
      mode: mode
    }
  end

  def rolls(%__MODULE__{} = drop, rolls) do
    case drop.mode do
      :random -> Enum.take_random(rolls, length(rolls) - drop.number)
      :low -> Enum.sort_by(rolls, & &1.result) |> Enum.drop(drop.number)
      :high -> Enum.sort_by(rolls, & &1.result) |> Enum.drop(-drop.number)
    end
  end

  defimpl Alea.Dice.Pool.Modifier do
    def apply(%Alea.Dice.Pool.Modifier.Drop{} = drop, pool) do
      pool = Alea.Dice.Pool.roll_all(pool)
      %Alea.Dice.Pool{pool | rolls: Alea.Dice.Pool.Modifier.Drop.rolls(drop, pool.rolls)}
    end
  end
end
