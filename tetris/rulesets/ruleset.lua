local Object = require 'libs.classic'
local Piece = require 'tetris.components.piece'

local Ruleset = Object:extend()

Ruleset.name = ""
Ruleset.hash = ""

-- Arika-type ruleset defaults
Ruleset.world = false
Ruleset.colourscheme = {
	I = "R",
	L = "O",
	J = "B",
	S = "M",
	Z = "G",
	O = "Y",
	T = "C",
}
Ruleset.softdrop_lock = true
Ruleset.harddrop_lock = false

Ruleset.enable_IRS_wallkicks = false
Ruleset.are_cancel = false
Ruleset.are = true
Ruleset.spawn_above_field = false

Ruleset.next_sounds = {
		I = "I",
		L = "L",
		J = "J",
		S = "S",
		Z = "Z",
		O = "O",
		T = "T"
}

-- Component functions.

function Ruleset:new(game_mode)
	self.game = game_mode
	local bones
	if config.gamesettings.piece_colour == 1 then
		bones = self.world and "w" or ""
	else
		bones = config.gamesettings.piece_colour == 3 and "w" or ""
	end
	for colour in pairs(blocks["2tie"]) do
		blocks.bone[colour] = love.graphics.newImage(
			"res/img/bone" .. bones .. ".png"
		)
	end
end

function Ruleset:rotatePiece(inputs, piece, grid, prev_inputs, initial)
	local new_inputs = {}

	for input, value in pairs(inputs) do
		if value and not prev_inputs[input] then
			new_inputs[input] = true
		end
	end

	local was_drop_blocked = piece:isDropBlocked(grid)

	if self:canPieceRotate(piece, grid) then
		self:attemptRotate(new_inputs, piece, grid, initial)
	end

	if not initial and not was_drop_blocked and piece:isDropBlocked(grid) then
		playSE("bottom")
	end

	-- prev_inputs becomes the previous inputs
	for input, value in pairs(inputs) do
		prev_inputs[input] = inputs[input]
	end
end

function Ruleset:attemptRotate(new_inputs, piece, grid, initial)
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

	if (grid:canPlacePiece(new_piece)) then
		piece:setRelativeRotation(rot_dir)
		self:onPieceRotate(piece, grid)
		playSE("rotate")
	else
		if not(initial and self.enable_IRS_wallkicks == false) then
			self:attemptWallkicks(piece, new_piece, rot_dir, grid)
		end
		playSE("kick")
	end
end

function Ruleset:attemptWallkicks(piece, new_piece, rot_dir, grid)
	-- do nothing in default ruleset
end

function Ruleset:movePiece(piece, grid, move, instant)
	if not self:canPieceMove(piece, grid) then return end
	local block_offset = (piece.big and not piece.half_block) and 2 or 1
	local was_drop_blocked = piece:isDropBlocked(grid)
	local offset = ({x=0, y=0})
	local moves = 0
	local y = piece.position.y
	if move == "left" then
		offset.x = -1
		moves = block_offset
	elseif move == "right" then
		offset.x = 1
		moves = block_offset
	elseif move == "speedleft" then
		offset.x = -1
		moves = grid.width
	elseif move == "speedright" then
		offset.x = 1
		moves = grid.width
	end
	for i = 1, moves do
		local x = piece.position.x
		if moves ~= 1 then
			piece:moveInGrid(offset, 1, grid, instant)
		else
			piece:moveInGrid(offset, 1, grid, false)
		end
		--this big piece fix is jank
		if piece.position.x ~= x and (block_offset == 1 or i % 2 == 0) then
			self:onPieceMove(piece, grid)
			if piece.locked then break end
		end
	end
	if not was_drop_blocked and piece:isDropBlocked(grid) then
		playSE("bottom")
	end
	if instant and piece.position.y ~= y then
		self:onPieceDrop(piece, grid)
	end
end

function Ruleset:dropPiece(
	inputs, piece, grid, gravity, drop_speed, drop_locked, hard_drop_locked,
	hard_drop_enabled, additive_gravity, classic_lock
)
	local y = piece.position.y
	if inputs["up"] == true and hard_drop_enabled == true then
		if hard_drop_locked == true or piece:isDropBlocked(grid) then
			piece:addGravity(gravity, grid, classic_lock)
		else
			piece:dropToBottom(grid)
		end
	elseif inputs["down"] == true and drop_locked == false then
		if additive_gravity then
			piece:addGravity(gravity + drop_speed, grid, classic_lock)
		else
			piece:addGravity(math.max(gravity, drop_speed), grid, classic_lock)
		end
	else
		piece:addGravity(gravity, grid, classic_lock)
	end
	if piece.position.y ~= y then
		self:onPieceDrop(piece, grid)
	end
end

function Ruleset:lockPiece(piece, grid, lock_delay, classic_lock)
	if piece:isDropBlocked(grid) and (
		(classic_lock and piece.gravity >= 1) or
		(not classic_lock and piece.lock_delay >= lock_delay)
	) then
		piece.locked = true
	end
end

function Ruleset:get180RotationValue() return 2 end
function Ruleset:getDefaultOrientation() return 1 end
function Ruleset:getDrawOffset(shape, orientation) return { x=0, y=0 } end
function Ruleset:getAboveFieldOffset(shape, orientation)
	if shape == "I" then
		return 1
	else
		return 2
	end
end

function Ruleset:initializePiece(
	inputs, data, grid, gravity, prev_inputs,
	move, lock_delay, drop_speed,
	drop_locked, hard_drop_locked, big, irs, half_block, offset
)
	local spawn_positions
	if big then
		spawn_positions = self.big_spawn_positions
	else
		spawn_positions = self.spawn_positions
	end

	local colours
	if table.equalvalues(
		table.keys(self.colourscheme), {"I", "J", "L", "O", "S", "T", "Z"}
	) then
		colours = ({self.colourscheme, ColourSchemes.Arika, ColourSchemes.TTC})[config.gamesettings.piece_colour]
	else
		colours = self.colourscheme
	end

	local spawn_x = math.floor(spawn_positions[data.shape].x * grid.width / 10)

	local spawn_dy
	if (config.gamesettings.spawn_positions == 1) then
		spawn_dy = (
			self.spawn_above_field and
			(self:getAboveFieldOffset(data.shape, data.orientation) * (big and 2 or 1)) or 0
		)
	else
		spawn_dy = (
			config.gamesettings.spawn_positions == 3 and
			(self:getAboveFieldOffset(data.shape, data.orientation) * (big and 2 or 1)) or 0
		)
	end

	local spawn_y = spawn_positions[data.shape].y - spawn_dy
	if big then
		spawn_x = spawn_x + math.floor(spawn_positions[data.shape].x * grid.width / 10)
		spawn_y = spawn_y + spawn_positions[data.shape].y
	end

	if offset then
		spawn_x = spawn_x + offset.x
		spawn_y = spawn_y + offset.y
	end

	local piece = Piece(data.shape, data.orientation - 1, {
		x = spawn_x,
		y = spawn_y
	}, self.block_offsets, 0, 0, data.skin, colours[data.shape], big, half_block)

	self:onPieceCreate(piece)
	if irs then
		self:rotatePiece(inputs, piece, grid, {}, true)
		if (data.orientation - 1) ~= piece.rotation then
			playSE("irs")
		end
	end
	return piece
end

-- stuff like move count, rotate count, floorkick count go here
function Ruleset:onPieceCreate(piece) end

function Ruleset:processPiece(
	inputs, piece, grid, gravity, prev_inputs,
	move, lock_delay, drop_speed,
	drop_locked, hard_drop_locked,
	hard_drop_enabled, additive_gravity, classic_lock
)
	local synchroes_allowed = ({self.synchroes == nil and not self.world or self.synchroes, true, false})[config.gamesettings.synchroes_allowed]

	if synchroes_allowed then
		self:rotatePiece(inputs, piece, grid, prev_inputs, false)
		self:movePiece(piece, grid, move, gravity >= grid.height - 4)
	else
		self:movePiece(piece, grid, move, gravity >= grid.height - 4)
		self:rotatePiece(inputs, piece, grid, prev_inputs, false)
	end
	self:dropPiece(
		inputs, piece, grid, gravity, drop_speed, drop_locked, hard_drop_locked,
		hard_drop_enabled, additive_gravity, classic_lock
	)
	self:lockPiece(piece, grid, lock_delay, classic_lock)
end

function Ruleset:canPieceMove(piece, grid) return true end
function Ruleset:canPieceRotate(piece, grid) return true end
function Ruleset:onPieceMove(piece, grid) end
function Ruleset:onPieceRotate(piece, grid) end
function Ruleset:onPieceDrop(piece, grid) end

return Ruleset
