defprotocol Alea.Die.Roll do
  defstruct [:die, :result]

  def roll(die)
end
