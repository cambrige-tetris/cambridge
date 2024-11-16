require 'funcs'

local GameMode = require 'tetris.modes.gamemode'
local Piece = require 'tetris.components.piece'

local History6RollsRandomizer = require 'tetris.randomizers.history_6rolls'

local PhantomManiaGame = GameMode:extend()

PhantomManiaGame.name = "Phantom Mania"
PhantomManiaGame.hash = "PhantomMania"
PhantomManiaGame.tagline = "The blocks disappear as soon as they're locked! Can you remember where everything is?"

function PhantomManiaGame:new()
	PhantomManiaGame.super:new()

	self.lock_drop = true
	self.lock_hard_drop = true
	self.next_queue_length = 1

	self.SGnames = {
		"S1", "S2", "S3", "S4", "S5", "S6", "S7", "S8", "S9",
		"M1", "M2", "M3", "M4", "M5", "M6", "M7", "M8", "M9",
		"GM"
	}

	self.roll_frames = 0
	self.combo = 1
	self.tetrises = 0
	self.section_tetrises = {[0] = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	self.randomizer = History6RollsRandomizer()
end

function PhantomManiaGame:getARE()
		if self.level < 100 then return 18
	elseif self.level < 200 then return 14
	elseif self.level < 400 then return 8
	elseif self.level < 500 then return 7
	else return 6 end
end

function PhantomManiaGame:getLineARE()
		if self.level < 100 then return 14
	elseif self.level < 400 then return 8
	elseif self.level < 500 then return 7
	else return 6 end
end

function PhantomManiaGame:getDasLimit()
		if self.level < 200 then return 11
	elseif self.level < 300 then return 10
	elseif self.level < 400 then return 9
	else return 7 end
end

function PhantomManiaGame:getLineClearDelay()
	return self:getLineARE() - 2
end

function PhantomManiaGame:getLockDelay()
		if self.level < 100 then return 30
	elseif self.level < 200 then return 26
	elseif self.level < 300 then return 22
	elseif self.level < 400 then return 18
	else return 15 end
end

function PhantomManiaGame:getGravity()
	return 20
end

function PhantomManiaGame:hitTorikan(old_level, new_level)
	if old_level < 300 and new_level >= 300 and self.frames > frameTime(2,28) then
		self.level = 300
		return true
	end
	if old_level < 500 and new_level >= 500 and self.frames > frameTime(3,38) then
		self.level = 500
		return true
	end
	if old_level < 800 and new_level >= 800 and self.frames > frameTime(5,23) then
		self.level = 800
		return true
	end
	return false
end

function PhantomManiaGame:advanceOneFrame()
	if self.clear then
		self.roll_frames = self.roll_frames + 1
		if self.roll_frames < 0 then
			return false
		elseif self.roll_frames > 1982 then
			self.completed = true
		end
	elseif self.ready_frames == 0 then
		self.frames = self.frames + 1
	end
	return true
end

function PhantomManiaGame:onPieceEnter()
	if (self.level % 100 ~= 99 and self.level ~= 998) and not self.clear and self.frames ~= 0 then
		self.level = self.level + 1
	end
end

function PhantomManiaGame:onLineClear(cleared_row_count)
	if not self.clear then
		if cleared_row_count >= 4 then
			self.tetrises = self.tetrises + 1
			self.section_tetrises[math.floor(self.level / 100)] = (
				self.section_tetrises[math.floor(self.level / 100)] + 1
			)
		end
		local new_level = self.level + cleared_row_count
		if new_level >= 999 or self:hitTorikan(self.level, new_level) then
			if new_level >= 999 then
				self.level = 999
			end
			self.clear = true
		else
			self.level = new_level
		end
	end
end

function PhantomManiaGame:updateScore(level, drop_bonus, cleared_lines)
	if not self.clear then
		if cleared_lines > 0 then
			self.combo = self.combo + (cleared_lines - 1) * 2
			self.score = self.score + (
				(math.ceil((level + cleared_lines) / 4) + drop_bonus) *
				cleared_lines * self.combo
			)
		else
			self.combo = 1
		end
		self.drop_bonus = 0
	end
end

PhantomManiaGame.rollOpacityFunction = function(age)
	if age > 4 then return 0
	else return 1 - age / 4 end
end

function PhantomManiaGame:drawGrid()
	if not (self.game_over or self.completed or (self.clear and self.level < 999)) then
		self.grid:drawInvisible(self.rollOpacityFunction, nil, false)
	else
		self.grid:draw()
	end
end

local function getLetterGrade(level, clear)
	if level < 300 or level == 300 and clear then
		return ""
	elseif level < 500 or level == 500 and clear then
		return "M"
	elseif level < 600 then
		return "MK"
	elseif level < 700 then
		return "MV"
	elseif level < 800 or level == 800 and clear then
		return "MO"
	elseif level <= 999 then
		return "MM"
	end
end

function PhantomManiaGame:qualifiesForGM()
    return true
end

function PhantomManiaGame:drawScoringInfo()
	PhantomManiaGame.super.drawScoringInfo(self)

	local text_x = config["side_next"] and 320 or 240

	love.graphics.setFont(font_3x5_2)
	if getLetterGrade(self.level, self.clear) ~= "" then
		love.graphics.printf("GRADE", text_x, 120, 40, "left")
	end
	love.graphics.printf("SCORE", text_x, 200, 40, "left")
	love.graphics.printf("LEVEL", text_x, 320, 40, "left")
	local sg = self.grid:checkSecretGrade()
	if sg >= 5 then
		love.graphics.printf("SECRET GRADE", 240, 430, 180, "left")
	end

	love.graphics.setFont(font_3x5_3)
	if getLetterGrade(self.level, self.clear) ~= "" then
		if self.roll_frames > 1982 then love.graphics.setColor(1, 0.5, 0, 1)
		elseif self.level == 999 and self.clear then love.graphics.setColor(0, 1, 0, 1) end
		if self.level == 999 and self:qualifiesForGM() then
			love.graphics.printf("GM", text_x, 140, 90, "left")
		else
			love.graphics.printf(getLetterGrade(self.level, self.clear), text_x, 140, 90, "left")
		end
		love.graphics.setColor(1, 1, 1, 1)
	end
	love.graphics.printf(self.score, text_x, 220, 90, "left")
	love.graphics.printf(self.level, text_x, 340, 40, "right")
	if self.clear then
		love.graphics.printf(self.level, text_x, 370, 40, "right")
	else
		love.graphics.printf(self:getSectionEndLevel(), text_x, 370, 40, "right")
	end

	if sg >= 5 then
		love.graphics.printf(self.SGnames[sg], 240, 450, 180, "left")
	end
end

function PhantomManiaGame:getSectionEndLevel()
	if self.level >= 900 then return 999
	else return math.floor(self.level / 100 + 1) * 100 end
end

function PhantomManiaGame:getBackground()
	return math.floor(self.level / 100)
end

function PhantomManiaGame:getHighscoreData()
	return {
		level = self.level,
		frames = self.frames,
	}
end

return PhantomManiaGame
