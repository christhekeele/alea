defprotocol Alea.Die.Sides do
  def random(faces)
  def min(faces)
  def max(faces)
  def count(faces)
end
