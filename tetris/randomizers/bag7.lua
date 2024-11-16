local Randomizer = require 'tetris.randomizers.randomizer'

local Bag7Randomizer = Randomizer:extend()

function Bag7Randomizer:initialize()
	self.bag = {"I", "J", "L", "O", "S", "T", "Z"}
end

function Bag7Randomizer:generatePiece()
	if next(self.bag) == nil then
		self.bag = {"I", "J", "L", "O", "S", "T", "Z"}
	end
	local x = love.math.random(#self.bag)
	return table.remove(self.bag, x)
end

return Bag7Randomizer
