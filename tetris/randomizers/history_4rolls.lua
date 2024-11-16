local Randomizer = require 'tetris.randomizers.randomizer'

local History4RollsRandomizer = Randomizer:extend()

function History4RollsRandomizer:initialize()
	self.history = {"Z", "Z", "Z", "Z"}
	self.first = true
end

function History4RollsRandomizer:generatePiece()
	if self.first then
		self.first = false
		return self:updateHistory(({"L", "J", "I", "T"})[love.math.random(4)])
	else
		local shapes = {"I", "J", "L", "O", "S", "T", "Z"}
		for i = 1, 4 do
			local x = love.math.random(7)
			if not self:inHistory(shapes[x]) or i == 4 then
				return self:updateHistory(shapes[x])
			end
		end
	end
end

function History4RollsRandomizer:updateHistory(shape)
	table.remove(self.history, 1)
	table.insert(self.history, shape)
	return shape
end

function History4RollsRandomizer:inHistory(piece)
	for idx, entry in pairs(self.history) do
		if entry == piece then
			return true
		end
	end
	return false
end

return History4RollsRandomizer
