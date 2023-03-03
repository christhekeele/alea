defmodule Dice.Parser.Builder do
  defmacro defparser(args \\ [], do: combinator) do
    Module.put_attribute(__CALLER__.module, :combinator, combinator)

    variable = args
    |> Keyword.get(:variable, __CALLER__.module |> Module.split |> List.last |> String.downcase |> String.to_atom)
    |> Macro.var(__CALLER__.module)

    quote location: :keep, generated: true do
      @before_compile {Dice.Parser.Module, :build_parser_module}

      def new(expression) when is_binary(expression) do
        expression |> parse |> validate!
      end

      def parse(input) when is_binary(input) do
        {:ok, [result: result], _unparsed, _context, _line, _offset} =
          unquote(Module.concat(__CALLER__.module, Parser)).parse(input)

        result
      end

      def validate!(unquote(variable)) do
        case validate(unquote(variable)) do
          {:ok, unquote(variable)} -> unquote(variable)
          {:error, reason} -> raise reason
        end
      end

      def valid?(unquote(variable)) do
        case validate(unquote(variable)) do
          {:ok, _} -> true
          {:error, _reason} -> false
        end
      end

      def validate(unquote(variable)) do
        {:ok, unquote(variable)}
      end
      defoverridable(validate: 1)

    end
  end
end
