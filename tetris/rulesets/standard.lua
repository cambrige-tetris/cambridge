local Piece = require 'tetris.components.piece'
local Ruleset = require 'tetris.rulesets.standard_ace'

local SRS = Ruleset:extend()

SRS.name = "Guideline SRS"
SRS.hash = "Standard"
SRS.softdrop_lock = false
SRS.harddrop_lock = true

SRS.enable_IRS_wallkicks = true

SRS.MANIPULATIONS_MAX = 15

SRS.wallkicks_line = {
	[0]={
		[1]={{x=-2, y=0}, {x=1, y=0}, {x=-2, y=1}, {x=1, y=-2}},
		[2]={{x=-1,y=0},{x=-2,y=0},{x=1,y=0},{x=2,y=0},{x=0,y=1}},
		[3]={{x=-1, y=0}, {x=2, y=0}, {x=-1, y=-2}, {x=2, y=1}},
	},
	[1]={
		[0]={{x=2, y=0}, {x=-1, y=0}, {x=2, y=-1}, {x=-1, y=2}},
		[2]={{x=-1, y=0}, {x=2, y=0}, {x=-1, y=-2}, {x=2, y=1}},
		[3]={{x=0,y=1},{x=0,y=2},{x=0,y=-1},{x=0,y=-2},{x=-1,y=0}},
	},
	[2]={
		[0]={{x=1,y=0},{x=2,y=0},{x=-1,y=0},{x=-2,y=0},{x=0,y=-1}},
		[1]={{x=1, y=0}, {x=-2, y=0}, {x=1, y=2}, {x=-2, y=-1}},
		[3]={{x=2, y=0}, {x=-1, y=0}, {x=2, y=-1}, {x=-1, y=2}},
	},
	[3]={
		[0]={{x=1, y=0}, {x=-2, y=0}, {x=1, y=2}, {x=-2, y=-1}},
		[1]={{x=0,y=1},{x=0,y=2},{x=0,y=-1},{x=0,y=-2},{x=1,y=0}},
		[2]={{x=-2, y=0}, {x=1, y=0}, {x=-2, y=1}, {x=1, y=-2}},
	},
};


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
			self:onPieceRotate(piece, grid)
			return
		end
	end

end

function SRS:checkNewLow(piece)
	for _, block in pairs(piece:getBlockOffsets()) do
		local y = piece.position.y + block.y
		if y > piece.lowest_y then
			piece.manipulations = 0
			piece.rotations = 0
			piece.lowest_y = y
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
	if piece.manipulations >= self.MANIPULATIONS_MAX and piece:isDropBlocked(grid) then
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
	else
		piece.locked = false
	end
end

function SRS:onPieceRotate(piece, grid)
	piece.lock_delay = 0 -- rotate reset
	self:checkNewLow(piece)
	piece.manipulations = piece.manipulations + 1
	if piece.manipulations >= self.MANIPULATIONS_MAX then
		piece:moveInGrid({ x = 0, y = 1 }, 1, grid)
		if piece:isDropBlocked(grid) then
			piece.locked = true
		end
	end
end

function SRS:canPieceRotate() return true end

function SRS:get180RotationValue() return 2 end

return SRS
