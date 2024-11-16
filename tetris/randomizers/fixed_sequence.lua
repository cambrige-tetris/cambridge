local Randomizer = require 'tetris.randomizers.randomizer'

local Sequence = Randomizer:extend()

function Sequence:initialize()
	self.sequence = "IJLOT"
	self.counter = 0
end

function Sequence:generatePiece()
	local piece
	if type(self.sequence) == "string" then
		piece = string.sub(self.sequence, self.counter + 1, self.counter + 1)
	else
		piece = self.sequence[self.counter + 1]
	end
	self.counter = (self.counter + 1) % (#self.sequence)
	return piece
end

return Sequence