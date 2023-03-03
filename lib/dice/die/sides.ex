defprotocol Dice.Die.Sides do
  def random(faces)
  def min(faces)
  def max(faces)
  def count(faces)

  import Dice.Parser.Builder

  defparser do
    choice([
      parsec({Dice.Die.Sides.Faces.Parser, :combinator}),
      parsec({Dice.Die.Sides.Range.Parser, :combinator}),
      parsec({Dice.Die.Sides.List.Parser, :combinator})
    ])
  end
end
