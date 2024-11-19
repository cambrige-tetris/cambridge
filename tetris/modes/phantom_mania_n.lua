local PhantomManiaGame = require 'tetris.modes.phantom_mania'

local PhantomManiaNGame = PhantomManiaGame:extend()

PhantomManiaNGame.name = "Phantom Mania N"
PhantomManiaNGame.hash = "PhantomManiaN"
PhantomManiaNGame.tagline = "The old mode from Nullpomino, for Ti-ARS and SRS support."

function PhantomManiaNGame:new(secret_inputs)
	PhantomManiaNGame.super:new(secret_inputs)

	self.next_queue_length = 3
	self.enable_hold = true
end

function PhantomManiaNGame:qualifiesForGM()
	if self.tetrises < 31 then return false end
	for i = 0, 9 do
		if self.section_tetrises[i] < (i == 9 and 1 or 2) then
			return false
		end
	end
	return true
end

return PhantomManiaNGame
