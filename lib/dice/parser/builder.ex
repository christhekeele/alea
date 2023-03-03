defmodule Dice.Parser.Builder do
  defmacro defparser(_args \\ [], do: combinator) do
    Module.put_attribute(__CALLER__.module, :combinator, combinator)

    quote location: :keep do
      @behaviour Dice.Parser
      @before_compile {Dice.Parser.Module, :build_parser_module}

      def parse(input) when is_binary(input) do
        {:ok, [result: result], _unparsed, _context, _line, _offset} =
          unquote(Module.concat(__CALLER__.module, Parser)).parse(input)

        result
      end
    end
  end
end
