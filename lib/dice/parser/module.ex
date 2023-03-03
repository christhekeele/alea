defmodule Dice.Parser.Module do
  defmacro build_parser_module(env) do
    base_module_alias =
      env.module
      |> Module.split()
      |> Enum.map(&String.to_atom/1)

    combinator =
      env.module
      |> Module.get_attribute(:combinator)
      |> Macro.postwalk(fn
        {:__MODULE__, _meta, _context} -> {:__aliases__, [{:alias, false}], base_module_alias}
        other -> other
      end)

    quote location: :keep do
      defmodule unquote(Module.concat(env.module, Parser)) do
        import NimbleParsec
        import Dice.Parser.Helpers

        def combinator do
          unquote(combinator)
        end

        parser =
          unquote(combinator)
          |> unwrap_and_tag(:result)
          |> eos()

        defparsec(:parse, parser, inline: true, export_metadata: true)

        def generate do
          {__MODULE__, :parse}
          |> NimbleParsec.parsec()
          |> NimbleParsec.generate()
          |> parse
        end
      end
    end
  end
end
