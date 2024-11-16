local Piece = require 'tetris.components.piece'
local Ruleset = require 'tetris.rulesets.standard_ti'

local SRS = Ruleset:extend()

SRS.name = "SRS-X"
SRS.hash = "StandardEXP"
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
SRS.softdrop_lock = true
SRS.harddrop_lock = false

SRS.enable_IRS_wallkicks = true

SRS.MANIPULATIONS_MAX = 24
SRS.ROTATIONS_MAX = 12

function SRS:checkNewLow(piece)
	for _, block in pairs(piece:getBlockOffsets()) do
		local y = piece.position.y + block.y
		if y > piece.lowest_y then
			piece.lowest_y = y
		end
	end
end

-- Component functions.

function SRS:attemptWallkicks(piece, new_piece, rot_dir, grid)

	local kicks
	if piece.shape == "O" then
		return
	elseif piece.shape == "I" then
		kicks = SRS.wallkicks_line[piece.rotation][new_piece.rotation]
	else
		kicks = SRS.wallkicks_3x3[piece.rotation][new_piece.rotation]
	end

	assert(piece.rotation ~= new_piece.rotation)

	for idx, offset in pairs(kicks) do
		local kicked_piece = new_piece:withOffset(offset)
		if grid:canPlacePiece(kicked_piece) then
			piece:setRelativeRotation(rot_dir)
			piece:setOffset(offset)
			self:onPieceRotate(piece, grid, offset.y < 0)
			return
		end
	end

end

function SRS:onPieceCreate(piece, grid)
	piece.manipulations = 0
	piece.rotations = 0
	piece.lowest_y = -math.huge
end

function SRS:onPieceDrop(piece, grid)
	self:checkNewLow(piece)
	if (
		piece.manipulations >= self.MANIPULATIONS_MAX or
		piece.rotations >= self.ROTATIONS_MAX
	) and piece:isDropBlocked(grid) then
		piece.locked = true
	else
		piece.lock_delay = 0 -- step reset
	end
end

function SRS:onPieceMove(piece, grid)
	piece.lock_delay = 0 -- move reset
	if piece:isDropBlocked(grid) then
		piece.manipulations = piece.manipulations + 1
		if piece.manipulations >= SRS.MANIPULATIONS_MAX then
			piece.locked = true
		end
	end
end

function SRS:onPieceRotate(piece, grid, upward)
	piece.lock_delay = 0 -- rotate reset
	if upward or piece:isDropBlocked(grid) then
		piece.rotations = piece.rotations + 1
		if piece.rotations >= self.ROTATIONS_MAX and piece:isDropBlocked(grid) then
			piece.locked = true
		end
	end
end

function SRS:canPieceRotate(piece)
	return piece.rotations < self.ROTATIONS_MAX
end

function SRS:get180RotationValue() return 2 end

return SRS
