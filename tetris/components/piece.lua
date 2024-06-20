local Object = require 'libs.classic'

---@class Piece
---@field shape string
---@field rotation integer
---@field position {x:integer, y:integer}
---@field block_offsets table
---@field gravity number
---@field lock_delay number
---@field skin string
---@field colour string
---@field ghost boolean
---@field locked boolean
---@field big boolean
---@field half_block boolean
local Piece = Object:extend()

---@param shape string
---@param rotation integer
---@param position {x:integer, y:integer}
---@param block_offsets table
---@param gravity number
---@param lock_delay number
---@param skin string
---@param colour string
---@param big boolean
---@param half_block boolean
function Piece:new(shape, rotation, position, block_offsets, gravity, lock_delay, skin, colour, big, half_block)
	self.shape = shape
	self.rotation = rotation
	self.position = position
	self.block_offsets = block_offsets
	self.gravity = gravity
	self.lock_delay = lock_delay
	self.skin = skin
	self.colour = colour
	self.ghost = false
	self.locked = false
	self.big = big
	self.half_block = half_block
end

-- Functions that return a new piece to test in rotation systems.

---@param offset {x:integer, y:integer}
---@param force_scale integer|nil
---@return Piece
---@nodiscard
function Piece:withOffset(offset, force_scale)
	local offset_scale = force_scale or self.big and 2 or 1
	return Piece(
		self.shape, self.rotation,
		{x = self.position.x + offset.x * offset_scale, y = self.position.y + offset.y * offset_scale},
		self.block_offsets, self.gravity, self.lock_delay, self.skin, self.colour, self.big
	)
end

---@nodiscard
function Piece:withRelativeRotation(rot)
	local new_rot = self.rotation + rot
	while new_rot < 0 do new_rot = new_rot + 4 end
	while new_rot >= 4 do new_rot = new_rot - 4 end
	return Piece(
		self.shape, new_rot, self.position,
		self.block_offsets, self.gravity, self.lock_delay, self.skin, self.colour, self.big
	)
end

-- Functions that return predicates relative to a grid.

---@nodiscard
---@return table
function Piece:getBlockOffsets()
	return self.block_offsets[self.shape][self.rotation + 1]
end

---@nodiscard
---@param x integer
---@param y integer
---@return boolean
function Piece:occupiesSquare(x, y)
	local offsets = self:getBlockOffsets()
	for index, offset in pairs(offsets) do
		local new_offset = {x = self.position.x + offset.x, y = self.position.y + offset.y}
		if new_offset.x == x and new_offset.y == y then
			return true
		end
	end
	return false
end

---@nodiscard
---@param grid Grid
---@return boolean
function Piece:isMoveBlocked(grid, offset)
	local moved_piece = self:withOffset(offset, 1)
	return not grid:canPlacePiece(moved_piece)
end

---@nodiscard
---@return boolean
function Piece:isDropBlocked(grid)
	return self:isMoveBlocked(grid, { x=0, y=1 })
end

-- Procedures to actually do stuff to pieces.

---@param offset {x:integer, y:integer}
---@param force_scale integer|nil
---@return Piece
function Piece:setOffset(offset, force_scale)
	local offset_scale = force_scale or self.big and 2 or 1
	self.position.x = self.position.x + offset.x * offset_scale
	self.position.y = self.position.y + offset.y * offset_scale
	return self
end

---@param rot integer
---@return Piece
function Piece:setRelativeRotation(rot)
	local new_rot = self.rotation + rot
	while new_rot < 0 do new_rot = new_rot + 4 end
	while new_rot >= 4 do new_rot = new_rot - 4 end
	self.rotation = new_rot
	return self
end

---@param step {x:integer, y:integer}
---@param squares integer
---@param instant boolean|nil
---@return Piece
function Piece:moveInGrid(step, squares, grid, instant)
	local moved = false
	for x = 1, squares do
		if grid:canPlacePiece(self:withOffset(step, 1)) then
			moved = true
			self:setOffset(step, 1)
			if instant then
				self:dropToBottom(grid)
			end
		else
			break
		end
	end
	if moved and step.y == 0 then playSE("move") end
	return self
end

---@param dropped_squares integer
---@param grid Grid
function Piece:dropSquares(dropped_squares, grid)
	self:moveInGrid({ x = 0, y = 1 }, dropped_squares, grid)
end

---@param grid Grid
---@return Piece
function Piece:dropToBottom(grid)
	local piece_y = self.position.y
	self:dropSquares(math.huge, grid)
	self.gravity = 0
	if self.position.y > piece_y then
		if self.ghost == false then playSE("bottom") end
		-- self.lock_delay = 0
	end
	return self
end

---@param grid Grid
---@return Piece
function Piece:lockIfBottomed(grid)
	if self:isDropBlocked(grid) then
		self.locked = true
	end
	return self
end

---@param gravity number
---@param grid Grid
---@param classic_lock boolean|nil
---@return Piece
function Piece:addGravity(gravity, grid, classic_lock)
	local new_gravity = self.gravity + gravity
	if self:isDropBlocked(grid) then
		if classic_lock then
			self.gravity = new_gravity
		else
			self.gravity = 0
			self.lock_delay = self.lock_delay + 1
		end
	elseif not (
		self:isMoveBlocked(grid, { x=0, y=-1 }) and gravity < 0
	) then
		local dropped_squares = math.floor(math.abs(new_gravity))
		if gravity >= 0 then
			local new_frac_gravity = new_gravity - dropped_squares
			self.gravity = new_frac_gravity
			self:dropSquares(dropped_squares, grid)
			if self:isDropBlocked(grid) then
				playSE("bottom")
			end
		else
			local new_frac_gravity = new_gravity + dropped_squares
			self.gravity = new_frac_gravity
			self:moveInGrid({ x=0, y=-1 }, dropped_squares, grid)
			if self:isMoveBlocked(grid, { x=0, y=-1 }) then
				playSE("bottom")
			end
		end
	else
		self.gravity = 0
	end
	-- a patch for infinite gravity
	if self.gravity ~= self.gravity then
		self.gravity = 0
	end
	return self
end

-- Procedures for drawing.

---@param opacity number|nil Must be in range of 0 to 1
---@param brightness number|nil Must be in range of 0 to 1
---@param grid Grid
---@param partial_das number|nil
function Piece:draw(opacity, brightness, grid, partial_das)
	if opacity == nil then opacity = 1 end
	if brightness == nil then brightness = 1 end
	love.graphics.setColor(brightness, brightness, brightness, opacity)
	local offsets = self:getBlockOffsets()
	local gravity_offset = 0
	if config.visualsettings.smooth_movement == 1 and 
	   grid ~= nil and not self:isDropBlocked(grid) then
		gravity_offset = self.gravity * 16
	end
	if partial_das == nil then partial_das = 0 end
	for index, offset in pairs(offsets) do
		local x = self.position.x + offset.x
		local y = self.position.y + offset.y
		if self.big then
			x = x + offset.x
			y = y + offset.y
			drawSizeIndependentImage(
				blocks[self.skin][self.colour],
				64+x*16+partial_das*2, 16+y*16+gravity_offset,
				0, 32, 32
			)
		else
			drawSizeIndependentImage(
				blocks[self.skin][self.colour],
				64+x*16+partial_das, 16+y*16+gravity_offset,
				0, 16, 16
			)
		end
	end
	return false
end

return Piece
