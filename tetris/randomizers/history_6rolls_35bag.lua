local Randomizer = require 'tetris.randomizers.randomizer'

local History6Rolls35PoolRandomizer = Randomizer:extend()

function History6Rolls35PoolRandomizer:initialize()
	self.first = true
	self.history = {"Z", "S", "Z", "S"}
	self.pool = {
		"I", "I", "I", "I", "I",
		"T", "T", "T", "T", "T",
		"L", "L", "L", "L", "L",
		"J", "J", "J", "J", "J",
		"S", "S", "S", "S", "S",
		"Z", "Z", "Z", "Z", "Z",
		"O", "O", "O", "O", "O",
	}
	self.droughts = {
		I = 0,
		T = 0,
		L = 0,
		J = 0,
		S = 0,
		Z = 0,
		O = 0,
	}
	self.piece_index = {
		"I",
		"T",
		"L",
		"J",
		"S",
		"Z",
		"O",
	}
end

function History6Rolls35PoolRandomizer:generatePiece()
	local index, x
	if self.first then
		index = love.math.random(20)
		x = self.pool[index]
		self.first = false
	else
		for i = 1, 6 do
			index = love.math.random(#self.pool)
			x = self.pool[index]
			if not self:inHistory(x) or i == 6 then
				break
			end
		end
	end
	self.pool[index] = self:updateHistory(x)
	return x
end

function History6Rolls35PoolRandomizer:updateHistory(shape)
	table.remove(self.history, 1)
	table.insert(self.history, shape)

	local highdrought
	local highdroughtcount = 0
	for k, v in pairs(self.piece_index) do
		if v == shape then
			self.droughts[v] = 0
		else
			self.droughts[v] = self.droughts[v] + 1
			if self.droughts[v] >= highdroughtcount then
				highdrought = v
				highdroughtcount = self.droughts[v]
			end
		end
	end
	return highdrought
end

function History6Rolls35PoolRandomizer:inHistory(piece)
	for idx, entry in pairs(self.history) do
		if entry == piece then
			return true
		end
	end
	return false
end

return History6Rolls35PoolRandomizer
