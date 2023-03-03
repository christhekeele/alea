defmodule Dice.Parser do
  @callback from_parse(unparsed, parsed, context, line, offset) :: {unparsed, parsed, context} | {:error, reason :: any}
            when unparsed: binary,
                 parsed: list,
                 context: any,
                 line: {pos_integer, non_neg_integer},
                 offset: non_neg_integer()
end

defmodule Dice.Term.Parser do
  defp term_combinator do
    import NimbleParsec
    import Dice.Parser.Helpers

    terms = [
      Dice.Pool.Parser.combinator(),
      Dice.Constant.Parser.combinator()
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
    import Dice.Parser.Helpers

    concat(
      concat(
        unwrap_and_tag(choice([positive_literal(), negative_literal()]), :sign),
        optional(whitespace_literal())
      ),
      term_combinator()
    )
    |> post_traverse({__MODULE__, :combinator_constructor, []})
  end

  def maybe_signed_term_combinator do
    import NimbleParsec
    choice([unsigned_term_combinator(), signed_term_combinator()])
  end

  def combinator_constructor(rest, args, context, _line, _offset) do
    sign =
      case Keyword.get(args, :sign, "+") do
        "+" -> :+
        "-" -> :-
      end

    term = Keyword.fetch!(args, :term)

    term = %Dice.Term{
      sign: sign,
      term: term
    }

    {rest, [term], context}
  end
end
