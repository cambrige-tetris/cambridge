require 'funcs'

local GameMode = require 'tetris.modes.gamemode'
local Piece = require 'tetris.components.piece'

local History6RollsRandomizer = require 'tetris.randomizers.history_6rolls'

local SurvivalA2Game = GameMode:extend()

SurvivalA2Game.name = "Survival A2"
SurvivalA2Game.hash = "SurvivalA2"
SurvivalA2Game.tagline = "The game starts fast and only gets faster!"




function SurvivalA2Game:new(secret_inputs)
	SurvivalA2Game.super:new(secret_inputs)

	for key, value in pairs(secret_inputs) do
		if value == true then
			self.secret_erasure = true
		end
	end

	setTargetFPS(61.68)
	self.roll_frames = 0
	self.combo = 1
	self.randomizer = History6RollsRandomizer()

	self.SGnames = {
		"9", "8", "7", "6", "5", "4", "3", "2", "1",
		"S1", "S2", "S3", "S4", "S5", "S6", "S7", "S8", "S9",
		"GM"
	}

	self.lock_drop = true
	self.lock_hard_drop = true
end

function SurvivalA2Game:onExit()
	setTargetFPS(60)
end

function SurvivalA2Game:getARE()
		if self.level < 100 then return 18
	elseif self.level < 300 then return 14
	elseif self.level < 400 then return 8
	elseif self.level < 500 then return 7
	else return 6 end
end

function SurvivalA2Game:getLineARE()
		if self.level < 100 then return 14
	elseif self.level < 400 then return 8
	elseif self.level < 500 then return 7
	else return 6 end
end

function SurvivalA2Game:getDasLimit()
		if self.level < 200 then return 11
	elseif self.level < 300 then return 10
	elseif self.level < 400 then return 9
	else return 7 end
end

function SurvivalA2Game:getLineClearDelay()
	return self:getLineARE() - 2
end

function SurvivalA2Game:getLockDelay()
		if self.level < 100 then return 30
	elseif self.level < 200 then return 26
	elseif self.level < 300 then return 22
	elseif self.level < 400 then return 18
	else return 15 end
end

function SurvivalA2Game:getGravity()
	return 20
end

function SurvivalA2Game:hitTorikan(old_level, new_level)
	if old_level < 500 and new_level >= 500 and self.frames > frameTime(3,25) then
		self.level = 500
		return true
	end
	return false
end

function SurvivalA2Game:advanceOneFrame()
	if self.secret_erasure then
		for i = 1, 3 do
			self.grid:clearSpecificRow(i)
		end
	end
	if self.clear then
		self.roll_frames = self.roll_frames + 1
		if self.roll_frames > 1800 then
			self.completed = true
		end
	elseif self.ready_frames == 0 then
		self.frames = self.frames + 1
	end
	return true
end

function SurvivalA2Game:onPieceEnter()
	if (self.level % 100 ~= 99 and self.level ~= 998) and not self.clear and self.frames ~= 0 then
		self.level = self.level + 1
	end
end

function SurvivalA2Game:onLineClear(cleared_row_count)
	if not self.clear then
		local new_level = math.min(self.level + cleared_row_count, 999)
		if new_level == 999 or self:hitTorikan(self.level, new_level) then
			self.clear = true
			if new_level < 999 then
				self.game_over = true
				return
			end
		end
		self.level = new_level
	end
end

function SurvivalA2Game:updateScore(level, drop_bonus, cleared_lines)
	if not self.clear then
		if self.grid:checkForBravo(cleared_lines) then self.bravo = 4 else self.bravo = 1 end
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

function SurvivalA2Game:getLetterGrade()
		if self.level >= 999 then return "GM"
	elseif self.level >  500 then return "M"
	elseif self.level == 500 and not self.clear then return "M"
	else return "" end
end

function SurvivalA2Game:drawGrid()
	self.grid:draw()
end

function SurvivalA2Game:drawScoringInfo()
	SurvivalA2Game.super.drawScoringInfo(self)
	love.graphics.setColor(1, 1, 1, 1)

	local text_x = config["side_next"] and 320 or 240

	love.graphics.setFont(font_3x5)
	love.graphics.print(
		self.das.direction .. " " ..
		self.das.frames .. " " ..
		strTrueValues(self.prev_inputs)
	)
	
	love.graphics.setFont(font_3x5_2)
	love.graphics.printf("NEXT", 64, 40, 40, "left")
	if self:getLetterGrade() ~= "" then love.graphics.printf("GRADE", text_x, 120, 40, "left") end
	love.graphics.printf("SCORE", text_x, 200, 40, "left")
	love.graphics.printf("LEVEL", text_x, 320, 40, "left")
	local sg = self.grid:checkSecretGrade()
	if sg >= 5 then
		love.graphics.printf("SECRET GRADE", 240, 430, 180, "left")
	end

	love.graphics.setFont(font_3x5_3)
	love.graphics.printf(self.score, text_x, 220, 90, "left")
	if self:getLetterGrade() ~= "" then love.graphics.printf(self:getLetterGrade(), text_x, 140, 90, "left") end
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.printf(self.level, text_x, 340, 40, "right")
	love.graphics.printf(self:getSectionEndLevel(), text_x, 370, 40, "right")
	if sg >= 5 then
		love.graphics.printf(self.SGnames[sg], 240, 450, 180, "left")
	end
end

function SurvivalA2Game:getSectionEndLevel()
	if self.clear then return self.level
	elseif self.level >= 900 then return 999
	else return math.floor(self.level / 100 + 1) * 100 end
end

function SurvivalA2Game:getBackground()
	return math.floor(self.level / 100)
end

function SurvivalA2Game:getHighscoreData()
	return {
		level = self.level,
		frames = self.frames,
	}
end

return SurvivalA2Game
