defmodule Alea.Expression.Parser.Module do
  defmacro build_parser_module(env) do
    base_module_alias =
      env.module
      |> Module.split()
      |> Enum.map(&String.to_atom/1)

    combinator =
      env.module
      |> Module.get_attribute(:combinator)
      |> Macro.postwalk(fn
        {:__MODULE__, _, _} -> {:__aliases__, [{:alias, false}], base_module_alias}
        other -> other
      end)
      |> Macro.postwalk(fn
        {:@, _, [{attribute, _, _}]} ->
          {{:., [], [{:__aliases__, [alias: false], [:Module]}, :get_attribute]}, [],
           [{:__aliases__, [alias: false], base_module_alias}, attribute]}

        other ->
          other
      end)

    quote location: :keep, generated: true do
      defmodule unquote(Module.concat(env.module, Parser)) do
        import NimbleParsec
        import Alea.Expression.Parser.Helpers

        def combinator do
          unquote(combinator)
        end

        # defparsec(:parse, unquote(combinator), inline: true, export_metadata: true)
        defcombinator(:combinator, empty() |> concat(unquote(combinator)),
          inline: true,
          export_metadata: true
        )

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
