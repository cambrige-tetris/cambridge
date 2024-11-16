local Piece = require 'tetris.components.piece'
local Ruleset = require 'tetris.rulesets.arika'

local ARS = Ruleset:extend()

ARS.name = "Ti-ARS"
ARS.hash = "ArikaTI"

ARS.synchroes = true
-- Component functions.

function ARS:attemptWallkicks(piece, new_piece, rot_dir, grid)

	-- O doesn't kick
	if (piece.shape == "O") then return end

	-- center column rule
	if (
		piece.shape == "J" or piece.shape == "T" or piece.shape == "L"
	) and (
		piece.rotation == 0 or piece.rotation == 2
	) then
		local offsets = new_piece:getBlockOffsets()
		table.sort(offsets, function(A, B) return A.y < B.y or A.y == B.y and A.x < B.y end)
		for index, offset in pairs(offsets) do
			if grid:isOccupied(piece.position.x + offset.x, piece.position.y + offset.y) then
				if offset.x == 0 then
					return
				else
					break
				end
			end
		end
	end

	if piece.shape == "I" then
		-- special kick rules for I
		if (new_piece.rotation == 0 or new_piece.rotation == 2) and
		(piece:isMoveBlocked(grid, {x=-1, y=0}) or piece:isMoveBlocked(grid, {x=1, y=0})) then
			-- kick right, right2, left
			if grid:canPlacePiece(new_piece:withOffset({x=1, y=0})) then
				piece:setRelativeRotation(rot_dir):setOffset({x=1, y=0})
				self:onPieceRotate(piece, grid)
			elseif grid:canPlacePiece(new_piece:withOffset({x=2, y=0})) then
				piece:setRelativeRotation(rot_dir):setOffset({x=2, y=0})
				self:onPieceRotate(piece, grid)
			elseif grid:canPlacePiece(new_piece:withOffset({x=-1, y=0})) then
				piece:setRelativeRotation(rot_dir):setOffset({x=-1, y=0})
				self:onPieceRotate(piece, grid)
			end
		elseif piece:isDropBlocked(grid) and (new_piece.rotation == 1 or new_piece.rotation == 3) and piece.floorkick == 0 then
			-- kick up, up2
			if grid:canPlacePiece(new_piece:withOffset({x=0, y=-1})) then
				piece:setRelativeRotation(rot_dir):setOffset({x=0, y=-1})
				piece.floorkick = 1
				self:onPieceRotate(piece, grid, true)
			elseif grid:canPlacePiece(new_piece:withOffset({x=0, y=-2})) then
				piece:setRelativeRotation(rot_dir):setOffset({x=0, y=-2})
				piece.floorkick = 1
				self:onPieceRotate(piece, grid, true)
			end
		end
	else
		-- kick right, kick left
		if grid:canPlacePiece(new_piece:withOffset({x=1, y=0})) then
			piece:setRelativeRotation(rot_dir):setOffset({x=1, y=0})
			self:onPieceRotate(piece, grid)
		elseif grid:canPlacePiece(new_piece:withOffset({x=-1, y=0})) then
			piece:setRelativeRotation(rot_dir):setOffset({x=-1, y=0})
			self:onPieceRotate(piece, grid)
		elseif piece.shape == "T"
		   and new_piece.rotation == 0
		   and piece.floorkick == 0
		   and piece:isDropBlocked(grid)
		   and grid:canPlacePiece(new_piece:withOffset({x=0, y=-1}))
		then
			-- T floorkick
			piece.floorkick = piece.floorkick + 1
			piece:setRelativeRotation(rot_dir):setOffset({x=0, y=-1})
			self:onPieceRotate(piece, grid, true)
		end
	end

end

function ARS:onPieceCreate(piece, grid)
	piece.floorkick = 0
end

function ARS:onPieceDrop(piece, grid)
	piece.lock_delay = 0 -- step reset
	if piece.floorkick >= 2 and piece:isDropBlocked(grid) then
		piece.locked = true
	end
end

function ARS:onPieceRotate(piece, grid, floorkick)
	if piece.floorkick >= 2 and piece:isDropBlocked(grid) then
		piece.locked = true
	elseif piece.floorkick >= 1 and not floorkick then
		piece.floorkick = piece.floorkick + 1
	end
end

function ARS:get180RotationValue() return 3 end

function ARS:getDefaultOrientation() return 3 end  -- downward facing pieces by default

return ARS
