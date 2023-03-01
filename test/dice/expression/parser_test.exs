defmodule Dice.Expression.Parser.Test do
  use ExUnit.Case
  doctest Dice.Expression.Parser

  alias Dice.Expression

  describe "constants" do
    test "with single constant" do
      input = "0"
      expected = {:ok, [number: 0], "", %{}, {1, 0}, 1}
      assert Expression.Parser.tokenize(input) == expected

      input = "1"
      expected = {:ok, [number: 1], "", %{}, {1, 0}, 1}
      assert Expression.Parser.tokenize(input) == expected

      input = "123"
      expected = {:ok, [number: 123], "", %{}, {1, 0}, 3}
      assert Expression.Parser.tokenize(input) == expected
    end
    test "with single positive constant" do
      input = "+1"
      expected = {:ok, [positive: "+", number: 1], "", %{}, {1, 0}, 2}
      assert Expression.Parser.tokenize(input) == expected

      input = "+ 1"
      expected = {:ok, [positive: "+", whitespace: " ", number: 1], "", %{}, {1, 0}, 3}
      assert Expression.Parser.tokenize(input) == expected

      # input = "1"
      # expected = {:ok, [constant: 1], "", %{}, {1, 0}, 1}

      # assert Expression.Parser.tokenize(input) == expected

      # input = "123"
      # expected = {:ok, [constant: 123], "", %{}, {1, 0}, 3}

      # assert Expression.Parser.tokenize(input) == expected
    end

    test "adding multiple constants" do
      input = "1 + 2"
      expected = {:ok, [number: 1, whitespace: " ", positive: "+", whitespace: " ", number: 2], "", %{}, {1, 0}, 5}

      assert Expression.Parser.tokenize(input) == expected
    end
  end
end
