defmodule Alea.Dice.Pool do
  defstruct dice: [], modifiers: [], rolls: []

  def roll_all(%Alea.Dice.Pool{} = pool) do
    %Alea.Dice.Pool{
      pool
      | dice: [],
        rolls: (pool.rolls ++ pool.dice) |> Enum.map(&Alea.Die.Roll.roll/1)
    }
  end

  def evaluate(%Alea.Dice.Pool{modifiers: [modifier | modifiers]} = pool) do
    pool = %Alea.Dice.Pool{pool | modifiers: modifiers}
    Alea.Dice.Pool.Modifier.apply(modifier, pool)
  end

  def evaluate(%Alea.Dice.Pool{modifiers: []} = pool) do
    Alea.Dice.Pool.roll_all(pool)
  end
end
