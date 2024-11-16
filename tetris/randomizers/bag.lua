local Randomizer = require 'tetris.randomizers.randomizer'

local BagRandomizer = Randomizer:extend()

function BagRandomizer:new(piece_table)
    self.bag = {}
    self.possible_pieces = piece_table
end

function BagRandomizer:generatePiece()
	if next(self.bag) == nil then
		for _, v in pairs(self.possible_pieces) do
			table.insert(self.bag, v)
		end
	end
	local x = love.math.random(#self.bag)
	return table.remove(self.bag, x)
end

return BagRandomizer
