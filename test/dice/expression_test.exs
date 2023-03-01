defmodule Dice.Expression.Test do

  use ExUnit.Case
  doctest Dice.Expression

  alias Dice.Expression

  # test "constants" do
  #   input = "1"
  #   expected = %Expression{constants: [1]}

  #   assert Expression.parse(input) == expected
  # end

  # describe "whitespace" do
  #   test "with single constant with ignorable whitespace" do
  #     input = " 1"
  #     expected = %Expression{constants: [1]}
  #     assert Expression.parse(input) == expected

  #     input = "1 "
  #     expected = %Expression{constants: [1]}
  #     assert Expression.parse(input) == expected
  #   end
  # end

end
