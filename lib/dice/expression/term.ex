defmodule Dice.Expression.Term do
  defstruct [:term, sign: :+]

  def evaluate(%__MODULE__{} = term) do
    result = case term.term do
      %Dice.Expression.Constant{} = constant -> Dice.Expression.Constant.evaluate(constant)
      %Dice.Expression.Dice.Numeric.Dice.Roll{} = numeric_roll -> Dice.Expression.Dice.Numeric.Dice.Roll.evaluate(numeric_roll)
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
        %Dice.Expression.Constant{} = constant -> Dice.Expression.Constant.to_string(constant)
        %Dice.Expression.Dice.Numeric.Dice.Roll{} = numeric_roll -> Dice.Expression.Dice.Numeric.Dice.Roll.to_string(numeric_roll)
      end
    ])
  end

  defp term_combinator do
    import NimbleParsec
    import Dice.Expression.Literals

    terms = [
      Dice.Expression.Dice.Numeric.Dice.Roll.combinator(),
      Dice.Expression.Constant.combinator()
    ]

    unwrap_and_tag(choice(terms), :term)
  end

  def unsigned_term_combinator do
    import NimbleParsec
    term_combinator()
    |> post_traverse({__MODULE__, :combinator_constructor, []})
  end

  def signed_term_combinator do
    import NimbleParsec
    import Dice.Expression.Literals

    concat(
      concat(
        unwrap_and_tag(choice([positive_literal(), negative_literal()]), :sign),
        optional(whitespace_literal())
      ),
      term_combinator()
    ) |> post_traverse({__MODULE__, :combinator_constructor, []})
  end

  def maybe_signed_term_combinator do
    import NimbleParsec
    choice([unsigned_term_combinator(), signed_term_combinator()])
  end

  def combinator_constructor(rest, args, context, _line, _offset) do
    sign = case Keyword.get(args, :sign, "+") do
      "+" -> :+
      "-" -> :-
    end
    term = Keyword.fetch!(args, :term)

    term = %Dice.Expression.Term{
      sign: sign,
      term: term
    }

    {rest, [term], context}
  end
end
