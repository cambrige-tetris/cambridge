require 'funcs'

local GameMode = require 'tetris.modes.gamemode'
local Piece = require 'tetris.components.piece'

local History6RollsRandomizer = require 'tetris.randomizers.history_6rolls_35bag'

local SurvivalA3Game = GameMode:extend()

SurvivalA3Game.name = "Survival A3"
SurvivalA3Game.hash = "SurvivalA3"
SurvivalA3Game.tagline = "The blocks turn black and white! Can you make it to level 1300?"


function SurvivalA3Game:new(secret_inputs)
	SurvivalA3Game.super:new(secret_inputs)

	for key, value in pairs(secret_inputs) do
		if value == true then
			self.secret_erasure = true
		end
	end

	self.grade = 0
	self.garbage = 0
	self.clear = false
	self.completed = false
	self.roll_frames = 0
	self.combo = 1
	self.randomizer = History6RollsRandomizer()

	self.SGnames = {
		"S1", "S2", "S3", "S4", "S5", "S6", "S7", "S8", "S9",
		"M1", "M2", "M3", "M4", "M5", "M6", "M7", "M8", "M9",
		"GM"
	}

	self.lock_drop = true
	self.lock_hard_drop = true
	self.enable_hold = true
	self.next_queue_length = 3

	self.coolregret_message = "COOL!!"
	self.coolregret_timer = 0
end

function SurvivalA3Game:initialize(ruleset)
	self.torikan_time = frameTime(2,28)
	if ruleset.world then self.torikan_time = frameTime(3,03) end
	GameMode.initialize(self, ruleset)
end

function SurvivalA3Game:getARE()
		if self.level < 300 then return 12
	else return 6 end
end

function SurvivalA3Game:getLineARE()
		if self.level < 100 then return 8
	elseif self.level < 200 then return 7
	elseif self.level < 500 then return 6
	elseif self.level < 1300 then return 5
	else return 6 end
end

function SurvivalA3Game:getDasLimit()
		if self.level < 100 then return 9
	elseif self.level < 500 then return 7
	else return 5 end
end

function SurvivalA3Game:getLineClearDelay()
	if self.level < 1300 then return self:getLineARE() - 2
	else return 6 end
end

function SurvivalA3Game:getLockDelay()
		if self.level < 200 then return 18
	elseif self.level < 300 then return 17
	elseif self.level < 500 then return 15
	elseif self.level < 600 then return 13
	elseif self.level < 1100 then return 12
	elseif self.level < 1200 then return 10
	elseif self.level < 1300 then return 8
	else return 15 end
end

function SurvivalA3Game:getGravity()
	return 20
end

function SurvivalA3Game:getGarbageLimit()
	if self.level < 600 then return 20
	elseif self.level < 700 then return 18
	elseif self.level < 800 then return 10
	elseif self.level < 900 then return 9
	else return 8 end
end

function SurvivalA3Game:getSkin()
	return self.level >= 1000 and "bone" or "2tie"
end

function SurvivalA3Game:hitTorikan(old_level, new_level)
	if old_level < 500 and new_level >= 500 and self.frames > self.torikan_time then
		self.level = 500
		return true
	end
	if old_level < 1000 and new_level >= 1000 and self.frames > self.torikan_time*2 then
		self.level = 1000
		return true
	end
	return false
end

function SurvivalA3Game:advanceOneFrame()
	if self.secret_erasure then
		for i = 1, 3 do
			self.grid:clearSpecificRow(i)
		end
	end
	if self.clear then
		self.roll_frames = self.roll_frames + 1
		if self.roll_frames < 0 then
			if self.roll_frames + 1 == 0 then
				switchBGM("credit_roll", "gm3")
				return true
			end
			return false
		elseif self.roll_frames > 3238 then
			switchBGM(nil)
			self.completed = true
		end
	elseif self.ready_frames == 0 then
		self.frames = self.frames + 1
	end
	return true
end

function SurvivalA3Game:onPieceEnter()
	if (self.level % 100 ~= 99) and not self.clear and self.frames ~= 0 then
		self.level = self.level + 1
	end
end

local cleared_row_levels = {1, 2, 4, 6}

function SurvivalA3Game:onLineClear(cleared_row_count)
	if not self.clear then
		local new_level = self.level + cleared_row_levels[cleared_row_count]
		self:updateSectionTimes(self.level, new_level)
		if new_level >= 1300 or self:hitTorikan(self.level, new_level) then
			self.clear = true
			if new_level >= 1300 then
				self.level = 1300
				self.grid:clear()
				self.big_mode = true
				self.roll_frames = -150
			else
				self.game_over = true
			end
		else
			self.level = math.min(new_level, 1300)
		end
		self:advanceBottomRow(-cleared_row_count)
	end
end

function SurvivalA3Game:onPieceLock(piece, cleared_row_count)
	self.super:onPieceLock()
	if cleared_row_count == 0 then self:advanceBottomRow(1) end
end

function SurvivalA3Game:updateScore(level, drop_bonus, cleared_lines)
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

function SurvivalA3Game:updateSectionTimes(old_level, new_level)
	if math.floor(old_level / 100) < math.floor(new_level / 100) then
		local section = math.floor(old_level / 100) + 1
		local section_time = self.frames - self.section_start_time
		table.insert(self.section_times, section_time)
		self.section_start_time = self.frames
		if section_time <= frameTime(1,00) then
			self.grade = self.grade + 1
		else
			self.coolregret_message = "REGRET!!"
			self.coolregret_timer = 300
		end
	end
end

function SurvivalA3Game:advanceBottomRow(dx)
	if self.level >= 500 and self.level < 1000 then
		self.garbage = math.max(self.garbage + dx, 0)
		if self.garbage >= self:getGarbageLimit() then
			self.grid:copyBottomRow()
			self.garbage = 0
		end
	end
end

function SurvivalA3Game:drawGrid()
	self.grid:draw()
end

local function getLetterGrade(grade)
	if grade == 0 then
		return "1"
	else
		return "S" .. tostring(grade)
	end
end

function SurvivalA3Game:drawScoringInfo()
	SurvivalA3Game.super.drawScoringInfo(self)

	love.graphics.setColor(1, 1, 1, 1)

	local text_x = config["side_next"] and 320 or 240

	love.graphics.setFont(font_3x5_2)
	love.graphics.printf("GRADE", text_x, 120, 40, "left")
	love.graphics.printf("SCORE", text_x, 200, 40, "left")
	love.graphics.printf("LEVEL", text_x, 320, 40, "left")
	local sg = self.grid:checkSecretGrade()
	if sg >= 5 then
		love.graphics.printf("SECRET GRADE", 240, 430, 180, "left")
	end

	if(self.coolregret_timer > 0) then
		love.graphics.printf(self.coolregret_message, 64, 400, 160, "center")
		self.coolregret_timer = self.coolregret_timer - 1
	end

	local current_section = math.floor(self.level / 100) + 1
	self:drawSectionTimesWithSplits(current_section)

	love.graphics.setFont(font_3x5_3)
	if self.roll_frames > 3238 then love.graphics.setColor(1, 0.5, 0, 1)
		elseif self.level >= 1300 then love.graphics.setColor(0, 1, 0, 1) end
	love.graphics.printf(getLetterGrade(math.floor(self.grade)), text_x, 140, 90, "left")
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.printf(self.score, text_x, 220, 90, "left")
	love.graphics.printf(self.level, text_x, 340, 50, "right")
	if self.clear then
		love.graphics.printf(self.level, text_x, 370, 50, "right")
	else
		love.graphics.printf(math.floor(self.level / 100 + 1) * 100, text_x, 370, 50, "right")
	end
	if sg >= 5 then
		love.graphics.printf(self.SGnames[sg], 240, 450, 180, "left")
	end
end

function SurvivalA3Game:getBackground()
	return math.floor(self.level / 100)
end

function SurvivalA3Game:getHighscoreData()
	return {
		level = self.level,
		frames = self.frames,
		grade = self.grade,
	}
end

return SurvivalA3Game
