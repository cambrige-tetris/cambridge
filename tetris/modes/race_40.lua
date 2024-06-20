require 'funcs'

local GameMode = require 'tetris.modes.gamemode'
local Piece = require 'tetris.components.piece'

local Bag7Randomiser = require 'tetris.randomizers.bag7noSZOstart'

local Race40Game = GameMode:extend()

Race40Game.name = "Race 40"
Race40Game.hash = "Race40"
Race40Game.tagline = "How fast can you clear 40 lines?"


function Race40Game:new()
	Race40Game.super:new()

	self.lines = 0
	self.line_goal = 40
	self.pieces = 0
	self.randomizer = Bag7Randomiser()

	self.roll_frames = 0

	self.SGnames = {
			[0] = "",
		"9", "8", "7", "6", "5", "4", "3", "2", "1",
			"S1", "S2", "S3", "S4", "S5", "S6", "S7", "S8", "S9",
			"GM"
   	}
	self.upstacked = false

	self.lock_drop = true
	self.lock_hard_drop = true
	self.instant_hard_drop = true
	self.instant_soft_drop = false
	self.enable_hold = true
	self.next_queue_length = 6
end

function Race40Game:getDropSpeed()
	return 20
end

function Race40Game:getARR()
	return config.arr
end

function Race40Game:getARE()
	return 0
end

function Race40Game:getLineARE()
	return self:getARE()
end

function Race40Game:getDasLimit()
	return config.das
end

function Race40Game:getLineClearDelay()
	return 0
end

function Race40Game:getLockDelay()
	return 30
end

function Race40Game:getGravity()
	return 1/64
end

function Race40Game:getDasCutDelay()
	return config.dcd
end

function Race40Game:onPieceLock()
	self.super:onPieceLock()
	self.pieces = self.pieces + 1
end

function Race40Game:onLineClear(cleared_row_count)
	self.lines = self.lines + cleared_row_count
	if self.lines >= self.line_goal then
		self.completed = true
	end
end

function Race40Game:drawGrid(ruleset)
	self.grid:draw()
	if self.piece ~= nil then
		self:drawGhostPiece(ruleset)
	end
	if self.lines >= self.line_goal - 20 and self.lines < self.line_goal then
		local line_height = (self.lines - self.line_goal + 20) * 16 + 80
		love.graphics.setColor(1, 0, 0, 1)
		love.graphics.line(64, line_height, 224, line_height)
	end
end

function Race40Game:getHighscoreData()
	return {
		lines = self.lines,
		frames = self.frames,
	}
end

function Race40Game:getSecretGrade(sg)
	if sg == 19 then self.upstacked = true end
	if self.upstacked then return self.SGnames[14 + math.floor((20 - sg) / 4)]
	else return self.SGnames[math.floor((sg / 19) * 14)] end
end

function Race40Game:drawScoringInfo()
	Race40Game.super.drawScoringInfo(self)
	love.graphics.setColor(1, 1, 1, 1)

	local text_x = config["side_next"] and 320 or 240

	love.graphics.setFont(font_3x5_2)
	love.graphics.printf("NEXT", 64, 40, 40, "left")
	love.graphics.printf("LINES", text_x, 320, 40, "left")
	love.graphics.printf("line/min", text_x, 160, 80, "left")
	love.graphics.printf("piece/sec", text_x, 220, 80, "left")
	local sg = self.grid:checkSecretGrade()
		if sg >= 7 or self.upstacked then
			love.graphics.printf("SECRET GRADE", 240, 430, 180, "left")
		end

	love.graphics.setFont(font_3x5_3)
	love.graphics.printf(string.format("%.02f", self.lines / math.max(1, self.frames) * 3600), text_x, 180, 80, "left")
	love.graphics.printf(string.format("%.04f", self.pieces / math.max(1, self.frames) * 60), text_x, 240, 80, "left")
	if sg >= 7 or self.upstacked then
			love.graphics.printf(self:getSecretGrade(sg), 240, 450, 180, "left")
		end

	love.graphics.setFont(font_3x5_4)
	love.graphics.printf(math.max(0, self.line_goal - self.lines), text_x, 340, 40, "left")
end

function Race40Game:getBackground()
	return 2
end

return Race40Game
