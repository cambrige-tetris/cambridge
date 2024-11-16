local Piece = require 'tetris.components.piece'
local Ruleset = require 'tetris.rulesets.standard_ti'

local SRS = Ruleset:extend()

SRS.name = "ACE-SRS"
SRS.hash = "StandardACE"
SRS.world = true
SRS.colourscheme = {
	I = "C",
	L = "O",
	J = "B",
	S = "G",
	Z = "R",
	O = "Y",
	T = "M",
}
SRS.softdrop_lock = false
SRS.harddrop_lock = true
SRS.spawn_above_field = true

SRS.MANIPULATIONS_MAX = 128

function SRS:onPieceRotate(piece, grid, upward)
	piece.lock_delay = 0 -- rotate reset
	if upward or piece:isDropBlocked(grid) then
		piece.manipulations = piece.manipulations + 1
		if piece.manipulations >= self.MANIPULATIONS_MAX and piece:isDropBlocked(grid) then
			piece.locked = true
		end
	end
end

function SRS:canPieceRotate(piece)
	return piece.manipulations < self.MANIPULATIONS_MAX
end

return SRS
