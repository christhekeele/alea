defmodule Dice.Term do
  defstruct [:term, sign: :+]

  def evaluate(%__MODULE__{} = term) do
    result =
      case term.term do
        %Dice.Constant{} = constant -> Dice.Constant.evaluate(constant)
        %Dice.Pool{} = numeric_roll -> Dice.Pool.evaluate(numeric_roll)
      end

    case term.sign do
      :+ -> result
      :- -> -1 * result
    end
  end

  def to_string(%__MODULE__{} = term) do
    Enum.join([
      case term.sign do
        :+ -> "+ "
        :- -> "- "
      end,
      case term.term do
        %Dice.Constant{} = constant -> Dice.Constant.to_string(constant)
        %Dice.Pool{} = numeric_roll -> Dice.Pool.to_string(numeric_roll)
      end
    ])
  end
end
