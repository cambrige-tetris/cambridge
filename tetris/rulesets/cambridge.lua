local Piece = require 'tetris.components.piece'
local Ruleset = require 'tetris.rulesets.ruleset'

local CRS = Ruleset:extend()

CRS.name = "Cambridge"
CRS.hash = "Cambridge"
CRS.world = true

CRS.spawn_positions = {
	I = { x=5, y=4 },
	J = { x=4, y=5 },
	L = { x=4, y=5 },
	O = { x=5, y=5 },
	S = { x=4, y=5 },
	T = { x=4, y=5 },
	Z = { x=4, y=5 },
}

CRS.big_spawn_positions = {
	I = { x=3, y=2 },
	J = { x=2, y=3 },
	L = { x=2, y=3 },
	O = { x=3, y=3 },
	S = { x=2, y=3 },
	T = { x=2, y=3 },
	Z = { x=2, y=3 },
}

CRS.block_offsets = {
	I={
		{ {x=0, y=0}, {x=-1, y=0}, {x=-2, y=0}, {x=1, y=0} },
		{ {x=0, y=0}, {x=0, y=-1}, {x=0, y=1}, {x=0, y=2} },
		{ {x=0, y=1}, {x=-1, y=1}, {x=-2, y=1}, {x=1, y=1} },
		{ {x=-1, y=0}, {x=-1, y=-1}, {x=-1, y=1}, {x=-1, y=2} },
	},
	J={
		{ {x=0, y=0}, {x=-1, y=0}, {x=1, y=0}, {x=-1, y=-1} },
		{ {x=0, y=0}, {x=0, y=-1}, {x=0, y=1} , {x=1, y=-1} },
		{ {x=0, y=0}, {x=1, y=0}, {x=-1, y=0}, {x=1, y=1} },
		{ {x=0, y=0}, {x=0, y=1}, {x=0, y=-1}, {x=-1, y=1} },
	},
	L={
		{ {x=0, y=0}, {x=-1, y=0}, {x=1, y=0}, {x=1, y=-1} },
		{ {x=0, y=0}, {x=0, y=-1}, {x=0, y=1}, {x=1, y=1} },
		{ {x=0, y=0}, {x=1, y=0}, {x=-1, y=0}, {x=-1, y=1} },
		{ {x=0, y=0}, {x=0, y=1}, {x=0, y=-1}, {x=-1, y=-1} },
	},
	O={
		{ {x=0, y=0}, {x=-1, y=0}, {x=-1, y=-1}, {x=0, y=-1} },
		{ {x=0, y=0}, {x=-1, y=0}, {x=-1, y=-1}, {x=0, y=-1} },
		{ {x=0, y=0}, {x=-1, y=0}, {x=-1, y=-1}, {x=0, y=-1} },
		{ {x=0, y=0}, {x=-1, y=0}, {x=-1, y=-1}, {x=0, y=-1} },
	},
	S={
		{ {x=-1, y=0}, {x=0, y=0}, {x=0, y=-1}, {x=1, y=-1} },
		{ {x=0, y=0}, {x=0, y=-1}, {x=-1, y=-1}, {x=-1, y=-2} },
		{ {x=-1, y=0}, {x=0, y=0}, {x=0, y=-1}, {x=1, y=-1} },
		{ {x=0, y=0}, {x=0, y=-1}, {x=-1, y=-1}, {x=-1, y=-2} },
	},
	T={
		{ {x=0, y=0}, {x=-1, y=0}, {x=1, y=0}, {x=0, y=-1} },
		{ {x=0, y=0}, {x=0, y=-1}, {x=0, y=1}, {x=1, y=0} },
		{ {x=0, y=0}, {x=1, y=0}, {x=-1, y=0}, {x=0, y=1} },
		{ {x=0, y=0}, {x=0, y=1}, {x=0, y=-1}, {x=-1, y=0} },
	},
	Z={
		{ {x=1, y=0}, {x=0, y=0}, {x=0, y=-1}, {x=-1, y=-1} },
		{ {x=1, y=-2}, {x=1, y=-1}, {x=0, y=-1}, {x=0, y=0} },
		{ {x=1, y=0}, {x=0, y=0}, {x=0, y=-1}, {x=-1, y=-1} },
		{ {x=1, y=-2}, {x=1, y=-1}, {x=0, y=-1}, {x=0, y=0} },
	}
}

CRS.wallkicks = {
	I={
		[true] = {
			[0]={
				[1]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=-1}, {x=-1, y=-1}, {x=0, y=-2}, {x=-1, y=-2}},
				[2]={{x=0, y=0}},
				[3]={{x=0, y=0}, {x=1, y=0}, {x=0, y=-1}, {x=1, y=-1}, {x=0, y=-2}, {x=1, y=-2}},
			},
			[1]={
				[2]={{x=0, y=0}, {x=1, y=0}, {x=0, y=1}, {x=1, y=1}, {x=-1, y=0}, {x=2, y=0}, {x=-1, y=1}, {x=2, y=1}},
				[3]={{x=0, y=0}},
				[0]={{x=0, y=0}, {x=1, y=0}, {x=0, y=1}, {x=1, y=1}, {x=-1, y=0}, {x=2, y=0}, {x=-1, y=1}, {x=2, y=1}},
			},
			[2]={
				[3]={{x=0, y=0}, {x=1, y=0}, {x=0, y=-1}, {x=1, y=-1}, {x=0, y=-2}, {x=1, y=-2}},
				[0]={{x=0, y=0}},
				[1]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=-1}, {x=-1, y=-1}, {x=0, y=-2}, {x=-1, y=-2}},
			},
			[3]={
				[0]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=1}, {x=-1, y=1}, {x=1, y=0}, {x=-2, y=0}, {x=1, y=1}, {x=-2, y=1}},
				[1]={{x=0, y=0}},
				[2]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=1}, {x=-1, y=1}, {x=1, y=0}, {x=-2, y=0}, {x=1, y=1}, {x=-2, y=1}},
			},
		},
		[false] = {
			[0]={
				[1]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=-1}, {x=-1, y=-1}, {x=0, y=-2}, {x=-1, y=-2}},
				[2]={{x=0, y=0}},
				[3]={{x=0, y=0}, {x=1, y=0}, {x=0, y=-1}, {x=1, y=-1}, {x=0, y=-2}, {x=1, y=-2}},
			},
			[1]={
				[2]={{x=0, y=0}, {x=1, y=0}, {x=0, y=1}, {x=1, y=1}, {x=-1, y=0}, {x=2, y=0}, {x=-1, y=1}, {x=2, y=1}},
				[3]={{x=0, y=0}},
				[0]={{x=0, y=0}, {x=1, y=0}, {x=0, y=1}, {x=1, y=1}, {x=-1, y=0}, {x=2, y=0}, {x=-1, y=1}, {x=2, y=1}},
			},
			[2]={
				[3]={{x=0, y=0}, {x=1, y=0}, {x=0, y=-1}, {x=1, y=-1}, {x=0, y=-2}, {x=1, y=-2}},
				[0]={{x=0, y=0}},
				[1]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=-1}, {x=-1, y=-1}, {x=0, y=-2}, {x=-1, y=-2}},
			},
			[3]={
				[0]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=1}, {x=-1, y=1}, {x=1, y=0}, {x=-2, y=0}, {x=1, y=1}, {x=-2, y=1}},
				[1]={{x=0, y=0}},
				[2]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=1}, {x=-1, y=1}, {x=1, y=0}, {x=-2, y=0}, {x=1, y=1}, {x=-2, y=1}},
			},
		},
	},
	J={
		[true] = {
			[0]={
				[1]={{x=0, y=-1}, {x=-1, y=-1}, {x=0, y=0}, {x=-1, y=0}}, -- allows for the "J situp"
				[2]={{x=0, y=0}, {x=0, y=-1}},
				[3]={{x=0, y=-1}, {x=1, y=-1}, {x=0, y=0}, {x=1, y=0}},
			},
			[1]={
				[2]={{x=0, y=0}, {x=1, y=0}, {x=-1, y=0}},
				[3]={{x=0, y=0}, {x=0, y=1}, {x=0, y=-1}},
				[0]={{x=0, y=1}, {x=1, y=1}, {x=0, y=0}, {x=-1, y=1}, {x=1, y=0}},
			},
			[2]={
				[3]={{x=0, y=0}, {x=1, y=0}, {x=0, y=1}, {x=1, y=1}},
				[0]={{x=0, y=0}, {x=0, y=1}},
				[1]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=1}, {x=-1, y=1}},
			},
			[3]={
				[0]={{x=0, y=1}, {x=-1, y=1}, {x=0, y=0}, {x=1, y=1}, {x=-1, y=0}},
				[1]={{x=0, y=0}, {x=0, y=1}, {x=0, y=-1}},
				[2]={{x=0, y=0}, {x=-1, y=0}, {x=1, y=0}},
			},
		},
		[false] = {
			[0]={
				[1]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=1}, {x=-1, y=1}},
				[2]={{x=0, y=0}, {x=0, y=-1}},
				[3]={{x=0, y=0}, {x=1, y=0}, {x=0, y=1}, {x=1, y=1}},
			},
			[1]={
				[2]={{x=0, y=0}, {x=1, y=0}, {x=-1, y=0}},
				[3]={{x=0, y=0}, {x=0, y=1}, {x=0, y=-1}},
				[0]={{x=0, y=0}, {x=1, y=0}, {x=0, y=-1}, {x=-1, y=0}, {x=1, y=-1}},
			},
			[2]={
				[3]={{x=0, y=0}, {x=1, y=0}, {x=0, y=1}, {x=1, y=1}},
				[0]={{x=0, y=0}, {x=0, y=1}},
				[1]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=1}, {x=-1, y=1}},
			},
			[3]={
				[0]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=-1}, {x=1, y=0}, {x=-1, y=-1}},
				[1]={{x=0, y=0}, {x=0, y=1}, {x=0, y=-1}},
				[2]={{x=0, y=0}, {x=-1, y=0}, {x=1, y=0}},
			},
		},
	},
	L={
		[true] = {
			[0]={
				[1]={{x=0, y=-1}, {x=-1, y=-1}, {x=0, y=0}, {x=-1, y=0}},
				[2]={{x=0, y=0}, {x=0, y=-1}},
				[3]={{x=0, y=-1}, {x=1, y=-1}, {x=0, y=0}, {x=1, y=0}}, -- allows for the "L situp"
			},
			[1]={
				[2]={{x=0, y=0}, {x=1, y=0}, {x=-1, y=0}},
				[3]={{x=0, y=0}, {x=0, y=1}, {x=0, y=-1}},
				[0]={{x=0, y=0}, {x=1, y=0}, {x=0, y=-1}, {x=-1, y=0}, {x=1, y=-1}},
			},
			[2]={
				[3]={{x=0, y=0}, {x=1, y=0}, {x=0, y=1}, {x=1, y=1}},
				[0]={{x=0, y=0}, {x=0, y=1}},
				[1]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=1}, {x=-1, y=1}},
			},
			[3]={
				[0]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=-1}, {x=1, y=0}, {x=-1, y=-1}},
				[1]={{x=0, y=0}, {x=0, y=1}, {x=0, y=-1}},
				[2]={{x=0, y=0}, {x=-1, y=0}, {x=1, y=0}},
			},
		},
		[false] = {
			[0]={
				[1]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=1}, {x=-1, y=1}},
				[2]={{x=0, y=0}, {x=0, y=-1}},
				[3]={{x=0, y=0}, {x=1, y=0}, {x=0, y=1}, {x=1, y=1}},
			},
			[1]={
				[2]={{x=0, y=0}, {x=1, y=0}, {x=-1, y=0}},
				[3]={{x=0, y=0}, {x=0, y=1}, {x=0, y=-1}},
				[0]={{x=0, y=0}, {x=1, y=0}, {x=0, y=-1}, {x=-1, y=0}, {x=1, y=-1}},
			},
			[2]={
				[3]={{x=0, y=0}, {x=1, y=0}, {x=0, y=1}, {x=1, y=1}},
				[0]={{x=0, y=0}, {x=0, y=1}},
				[1]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=1}, {x=-1, y=1}},
			},
			[3]={
				[0]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=-1}, {x=1, y=0}, {x=-1, y=-1}},
				[1]={{x=0, y=0}, {x=0, y=1}, {x=0, y=-1}},
				[2]={{x=0, y=0}, {x=-1, y=0}, {x=1, y=0}},
			},
		},
	},
	S={
		[true] = {
			[0]={
				[1]={{x=0, y=1}, {x=-1, y=1}, {x=0, y=0}, {x=-1, y=0}},
				[2]={{x=0, y=0}, {x=-1, y=1}},
				[3]={{x=0, y=1}, {x=-1, y=1}, {x=0, y=0}, {x=-1, y=0}},
			},
			[1]={
				[0]={{x=0, y=0}, {x=1, y=0}, {x=0, y=-1}, {x=1, y=-1}},
				[2]={{x=0, y=0}, {x=1, y=0}, {x=0, y=-1}, {x=1, y=-1}},
				[3]={{x=0, y=0}, {x=1, y=1}},
			},
			[2]={
				[0]={{x=0, y=0}, {x=-1, y=1}},
				[1]={{x=0, y=1}, {x=-1, y=1}, {x=0, y=0}, {x=-1, y=0}},
				[3]={{x=0, y=1}, {x=-1, y=1}, {x=0, y=0}, {x=-1, y=0}},
			},
			[3]={
				[0]={{x=0, y=0}, {x=1, y=0}, {x=0, y=-1}, {x=1, y=-1}},
				[1]={{x=0, y=0}, {x=1, y=1}},
				[2]={{x=0, y=0}, {x=1, y=0}, {x=0, y=-1}, {x=1, y=-1}},
			},
		},
		[false] = {
			[0]={
				[1]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=1}, {x=-1, y=1}},
				[2]={{x=0, y=0}, {x=-1, y=1}},
				[3]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=1}, {x=-1, y=1}},
			},
			[1]={
				[0]={{x=0, y=0}, {x=1, y=0}, {x=0, y=-1}, {x=1, y=-1}},
				[2]={{x=0, y=0}, {x=1, y=0}, {x=0, y=-1}, {x=1, y=-1}},
				[3]={{x=0, y=0}, {x=1, y=1}},
			},
			[2]={
				[0]={{x=0, y=0}, {x=-1, y=1}},
				[1]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=1}, {x=-1, y=1}},
				[3]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=1}, {x=-1, y=1}},
			},
			[3]={
				[0]={{x=0, y=0}, {x=1, y=0}, {x=0, y=-1}, {x=1, y=-1}},
				[1]={{x=0, y=0}, {x=1, y=1}},
				[2]={{x=0, y=0}, {x=1, y=0}, {x=0, y=-1}, {x=1, y=-1}},
			},
		},
	},
	T={
		[true] = {
			[0]={
				[1]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=-1}, {x=-1, y=-1}},
				[2]={{x=0, y=0}, {x=0, y=-1}},
				[3]={{x=0, y=0}, {x=1, y=0}, {x=0, y=-1}, {x=1, y=-1}},
			},
			[1]={
				[0]={{x=0, y=1}, {x=1, y=1}, {x=0, y=0}, {x=1, y=0}}, -- prioritizes the nub T spin over the regular T spin
				[2]={{x=0, y=0}, {x=1, y=0}},
				[3]={{x=0, y=0}, {x=0, y=1}, {x=0, y=-1}},
			},
			[2]={
				[0]={{x=0, y=0}, {x=0, y=1}},
				[1]={{x=0, y=0}, {x=-1, y=0}},
				[3]={{x=0, y=0}, {x=1, y=0}},
			},
			[3]={
				[0]={{x=0, y=1}, {x=-1, y=1}, {x=0, y=0}, {x=-1, y=0}}, -- prioritizes the nub T spin over the regular T spin
				[1]={{x=0, y=0}, {x=0, y=1}, {x=0, y=-1}},
				[2]={{x=0, y=0}, {x=-1, y=0}},
			},
		},
		[false] = {
			[0]={
				[1]={{x=0, y=0}, {x=1, y=0}, {x=0, y=1}, {x=1, y=1}},
				[2]={{x=0, y=0}, {x=0, y=-1}},
				[3]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=1}, {x=-1, y=1}},
			},
			[1]={
				[0]={{x=0, y=0}, {x=1, y=0}, {x=0, y=-1}, {x=1, y=-1}},
				[2]={{x=0, y=0}, {x=1, y=0}},
				[3]={{x=0, y=0}, {x=0, y=1}, {x=0, y=-1}},
			},
			[2]={
				[0]={{x=0, y=0}, {x=0, y=1}},
				[1]={{x=0, y=0}, {x=-1, y=0}},
				[3]={{x=0, y=0}, {x=1, y=0}},
			},
			[3]={
				[0]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=-1}, {x=-1, y=-1}},
				[1]={{x=0, y=0}, {x=0, y=1}, {x=0, y=-1}},
				[2]={{x=0, y=0}, {x=-1, y=0}},
			},
		},
	},
	Z={
		[true] = {
			[0]={
				[1]={{x=0, y=1}, {x=1, y=1}, {x=0, y=0}, {x=1, y=0}},
				[2]={{x=0, y=0}, {x=1, y=1}},
				[3]={{x=0, y=1}, {x=1, y=1}, {x=0, y=0}, {x=1, y=0}},
			},
			[1]={
				[0]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=-1}, {x=-1, y=-1}},
				[2]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=-1}, {x=-1, y=-1}},
				[3]={{x=0, y=0}, {x=-1, y=1}},
			},
			[2]={
				[0]={{x=0, y=0}, {x=1, y=1}},
				[1]={{x=0, y=1}, {x=1, y=1}, {x=0, y=0}, {x=1, y=0}},
				[3]={{x=0, y=1}, {x=1, y=1}, {x=0, y=0}, {x=1, y=0}},
			},
			[3]={
				[0]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=-1}, {x=-1, y=-1}},
				[1]={{x=0, y=0}, {x=-1, y=1}},
				[2]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=-1}, {x=-1, y=-1}},
			},
		},
		[false] = {
			[0]={
				[1]={{x=0, y=0}, {x=1, y=0}, {x=0, y=1}, {x=1, y=1}},
				[2]={{x=0, y=0}, {x=1, y=1}},
				[3]={{x=0, y=0}, {x=1, y=0}, {x=0, y=1}, {x=1, y=1}},
			},
			[1]={
				[0]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=-1}, {x=-1, y=-1}},
				[2]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=-1}, {x=-1, y=-1}},
				[3]={{x=0, y=0}, {x=-1, y=1}},
			},
			[2]={
				[0]={{x=0, y=0}, {x=1, y=1}},
				[1]={{x=0, y=0}, {x=1, y=0}, {x=0, y=1}, {x=1, y=1}},
				[3]={{x=0, y=0}, {x=1, y=0}, {x=0, y=1}, {x=1, y=1}},
			},
			[3]={
				[0]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=-1}, {x=-1, y=-1}},
				[1]={{x=0, y=0}, {x=-1, y=1}},
				[2]={{x=0, y=0}, {x=-1, y=0}, {x=0, y=-1}, {x=-1, y=-1}},
			},
		},
	},
}

function CRS:attemptRotate(new_inputs, piece, grid, initial)
	local rot_dir = 0

	if (new_inputs["rotate_left"] or new_inputs["rotate_left2"]) then
		rot_dir = 3
	elseif (new_inputs["rotate_right"] or new_inputs["rotate_right2"]) then
		rot_dir = 1
	elseif (new_inputs["rotate_180"]) then
		rot_dir = self:get180RotationValue()
	end

	if rot_dir == 0 then return end

	if config.gamesettings.world_reverse == 3 or (self.world and config.gamesettings.world_reverse == 2) then
		rot_dir = 4 - rot_dir
	end

	local new_piece = piece:withRelativeRotation(rot_dir)
	self:attemptWallkicks(piece, new_piece, rot_dir, grid)
end


function CRS:attemptWallkicks(piece, new_piece, rot_dir, grid)

	if piece.shape == "O" then
		self:onPieceRotate(piece, grid)
		return
	end

	local kicks = CRS.wallkicks[piece.shape][piece:isDropBlocked(grid)][piece.rotation][new_piece.rotation]

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

function CRS:onPieceCreate(piece, grid)
	piece.rotate_counter = 0
	piece.move_counter = 0
end

function CRS:onPieceDrop(piece, grid)
	piece.lock_delay = 0 -- step reset
end

function CRS:onPieceMove(piece, grid)
	if piece:isDropBlocked(grid) then
		piece.move_counter = piece.move_counter + 1
		if piece.move_counter >= 24 then
			piece:dropToBottom(grid)
			piece.locked = true
		end
	end
end

function CRS:onPieceRotate(piece, grid)
	if piece:isDropBlocked(grid) then
		piece.rotate_counter = piece.rotate_counter + 1
		if piece.rotate_counter >= 12 then
			piece:dropToBottom(grid)
			piece.locked = true
		end
	end
end

function CRS:getDefaultOrientation() return 1 end  -- downward facing pieces by default

return CRS
