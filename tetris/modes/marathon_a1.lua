require 'funcs'

local GameMode = require 'tetris.modes.gamemode'
local Piece = require 'tetris.components.piece'
local Grid = require 'tetris.components.grid'

local History4RollsRandomizer = require 'tetris.randomizers.history_4rolls'

local MarathonA1Game = GameMode:extend()

MarathonA1Game.name = "Marathon A1"
MarathonA1Game.hash = "MarathonA1"
MarathonA1Game.tagline = "Can you score enough points to reach the title of Grand Master?"



function MarathonA1Game:new(secret_inputs)
	MarathonA1Game.super:new(secret_inputs)
	
	for key, value in pairs(secret_inputs) do
		if value == true then
			self.secret_erasure = true
		end
	end

	self.roll_frames = 0
	self.combo = 1
	self.bravos = 0
	self.gm_conditions = {
		level300 = false,
		level500 = false,
		level999 = false
	}
	self.SGnames = {
		"9", "8", "7", "6", "5", "4", "3", "2", "1",
		"S1", "S2", "S3", "S4", "S5", "S6", "S7", "S8", "S9",
		"GM"
	}
	
	self.randomizer = History4RollsRandomizer()

	self.additive_gravity = false
	self.lock_drop = false
	self.enable_hard_drop = false
	self.enable_hold = false
	self.next_queue_length = 1
end

function MarathonA1Game:getARE()
	return 30
end

function MarathonA1Game:getLineARE()
	return 27
end

function MarathonA1Game:getDasLimit()
	return 15
end

function MarathonA1Game:getLineClearDelay()
	return 44
end

function MarathonA1Game:getLockDelay()
	return 30
end

local function getRankForScore(score)
		if score <	400 then return {rank = "9", next = 400}
	elseif score <	800 then return {rank = "8", next = 800}
	elseif score <   1400 then return {rank = "7", next = 1400}
	elseif score <   2000 then return {rank = "6", next = 2000}
	elseif score <   3500 then return {rank = "5", next = 3500}
	elseif score <   5500 then return {rank = "4", next = 5500}
	elseif score <   8000 then return {rank = "3", next = 8000}
	elseif score <  12000 then return {rank = "2", next = 12000}
	elseif score <  16000 then return {rank = "1", next = 16000}
	elseif score <  22000 then return {rank = "S1", next = 22000}
	elseif score <  30000 then return {rank = "S2", next = 30000}
	elseif score <  40000 then return {rank = "S3", next = 40000}
	elseif score <  52000 then return {rank = "S4", next = 52000}
	elseif score <  66000 then return {rank = "S5", next = 66000}
	elseif score <  82000 then return {rank = "S6", next = 82000}
	elseif score < 100000 then return {rank = "S7", next = 100000}
	elseif score < 120000 then return {rank = "S8", next = 120000}
	else return {rank = "S9", next = "???"}
	end
end

function MarathonA1Game:getGravity()
	local level = self.level
		if (level < 30)  then return 4/256
	elseif (level < 35)  then return 6/256
	elseif (level < 40)  then return 8/256
	elseif (level < 50)  then return 10/256
	elseif (level < 60)  then return 12/256
	elseif (level < 70)  then return 16/256
	elseif (level < 80)  then return 32/256
	elseif (level < 90)  then return 48/256
	elseif (level < 100) then return 64/256
	elseif (level < 120) then return 80/256
	elseif (level < 140) then return 96/256
	elseif (level < 160) then return 112/256
	elseif (level < 170) then return 128/256
	elseif (level < 200) then return 144/256
	elseif (level < 220) then return 4/256
	elseif (level < 230) then return 32/256
	elseif (level < 233) then return 64/256
	elseif (level < 236) then return 96/256
	elseif (level < 239) then return 128/256
	elseif (level < 243) then return 160/256
	elseif (level < 247) then return 192/256
	elseif (level < 251) then return 224/256
	elseif (level < 300) then return 1
	elseif (level < 330) then return 2
	elseif (level < 360) then return 3
	elseif (level < 400) then return 4
	elseif (level < 420) then return 5
	elseif (level < 450) then return 4
	elseif (level < 500) then return 3
	else return 20
	end
end

function MarathonA1Game:advanceOneFrame()
	if self.secret_erasure then
		for i = 1, 3 do
			self.grid:clearSpecificRow(i)
		end
	end
	if self.clear then
		self.roll_frames = self.roll_frames + 1
		if self.roll_frames > 2968 then
			self.completed = true
		end
	elseif self.ready_frames == 0 then
		self.frames = self.frames + 1
	end
	return true
end

function MarathonA1Game:onPieceEnter()
	if (self.level % 100 ~= 99 and self.level ~= 998) and not self.clear and self.frames ~= 0 then
		self.level = self.level + 1
	end
end

function MarathonA1Game:onLineClear(cleared_row_count)
	self:checkGMRequirements(self.level, self.level + cleared_row_count)
	if not self.clear then
		local new_level = math.min(self.level + cleared_row_count, 999)
		if new_level == 999 then
			self.clear = true
		end
		self.level = new_level
	end
end

function MarathonA1Game:updateScore(level, drop_bonus, cleared_lines)
	if not self.clear then
		if self.grid:checkForBravo(cleared_lines) then
			self.bravo = 4
			self.bravos = self.bravos + 1
		else self.bravo = 1 end
		if cleared_lines > 0 then
			self.combo = self.combo + (cleared_lines - 1) * 2
			self.score = self.score + (
				(math.ceil((level + cleared_lines) / 4) + drop_bonus) *
				cleared_lines * self.combo * self.bravo
			)
		else
			self.combo = 1
		end
		self.drop_bonus = 0
	end
end

function MarathonA1Game:checkGMRequirements(old_level, new_level)
	if old_level < 300 and new_level >= 300 then
		if self.score >= 12000 and self.frames <= frameTime(4,15) then
			self.gm_conditions["level300"] = true
		end
	elseif old_level < 500 and new_level >= 500 then
		if self.score >= 40000 and self.frames <= frameTime(7,30) then
			self.gm_conditions["level500"] = true
		end
	elseif old_level < 999 and new_level >= 999 then
		if self.score >= 126000 and self.frames <= frameTime(13,30) then
			self.gm_conditions["level999"] = true
		end
	end
end

function MarathonA1Game:drawGrid()
	self.grid:draw()
	if self.piece ~= nil and self.level < 100 then
		self:drawGhostPiece(ruleset)
	end
end

function MarathonA1Game:drawScoringInfo()
	MarathonA1Game.super.drawScoringInfo(self)
	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.setFont(font_3x5)
	love.graphics.print(
		self.das.direction .. " " ..
		self.das.frames .. " " ..
		strTrueValues(self.prev_inputs)
	)

	love.graphics.setFont(font_3x5_2)
	love.graphics.printf("NEXT", 64, 40, 40, "left")
	love.graphics.printf("GRADE", 240, 120, 40, "left")
	love.graphics.printf("SCORE", 240, 200, 40, "left")
	love.graphics.printf("NEXT RANK", 240, 260, 90, "left")
	love.graphics.printf("LEVEL", 240, 320, 40, "left")
	local sg = self.grid:checkSecretGrade()
	if sg >= 5 then 
		love.graphics.printf("SECRET GRADE", 240, 430, 180, "left")
	end

	if self.bravos > 0 then love.graphics.printf("BRAVO", 300, 120, 40, "left") end

	love.graphics.setFont(font_3x5_3)
	love.graphics.printf(self.score, 240, 220, 90, "left")
	if self.gm_conditions["level300"] and self.gm_conditions["level500"] and self.gm_conditions["level999"] then
		love.graphics.printf("GM", 240, 140, 90, "left")
	else
		love.graphics.printf(getRankForScore(self.score).rank, 240, 140, 90, "left")
	end
	love.graphics.printf(getRankForScore(self.score).next, 240, 280, 90, "left")
	love.graphics.printf(self.level, 240, 340, 40, "right")
	love.graphics.printf(self:getSectionEndLevel(), 240, 370, 40, "right")
	if sg >= 5 then
		love.graphics.printf(self.SGnames[sg], 240, 450, 180, "left")
	end
	if self.bravos > 0 then love.graphics.printf(self.bravos, 300, 140, 40, "left") end
	
	love.graphics.setFont(font_8x11)
	love.graphics.printf(formatTime(self.frames), 64, 420, 160, "center")
end

function MarathonA1Game:getSectionEndLevel()
	if self.level >= 900 then return 999
	else return math.floor(self.level / 100 + 1) * 100 end
end

function MarathonA1Game:getBackground()
	return math.floor(self.level / 100)
end

function MarathonA1Game:getHighscoreData()
	return {
		grade = self.grade,
		score = self.score,
		level = self.level,
		frames = self.frames,
	}
end

return MarathonA1Game
