require 'funcs'

local GameMode = require 'tetris.modes.gamemode'
local Piece = require 'tetris.components.piece'

local History6RollsRandomizer = require 'tetris.randomizers.history_6rolls_35bag'

local Survival2020Game = GameMode:extend()

Survival2020Game.name = "Survival 2020"
Survival2020Game.hash = "Survival2020"
Survival2020Game.tagline = "A new time limit on the blocks! Can you handle being forced to perform under the total delay?"




function Survival2020Game:new()
	Survival2020Game.super:new()
	self.level = 0
	self.grade = 0
	self.garbage = 0
	self.clear = false
	self.completed = false
	self.roll_frames = 0
	self.combo = 1
	self.total_delay = 0
	self.randomizer = History6RollsRandomizer()

	self.lock_drop = true
	self.lock_hard_drop = true
	self.enable_hold = true
	self.next_queue_length = 3
end

function Survival2020Game:getARE()
		if self.level < 200 then return 12
	elseif self.level < 300 then return 10
	elseif self.level < 500 then return 6
	elseif self.level < 1000 then return 4
	elseif self.level < 1500 then return 5
	else return 6 end
end

function Survival2020Game:getLineARE()
	return self:getARE()
end

function Survival2020Game:getDasLimit()
		if self.level < 200 then return 9
	elseif self.level < 500 then return 7
	elseif self.level < 1000 then return 5
	elseif self.level < 1500 then return 4
	else return 3 end
end

function Survival2020Game:getLineClearDelay()
		if self.level < 300 then return 6
	elseif self.level < 500 then return 4
	else return 2 end
end

function Survival2020Game:getLockDelay()
		if self.level < 100 then return 20
	elseif self.level < 200 then return 18
	elseif self.level < 300 then return 17
	elseif self.level < 400 then return 15
	elseif self.level < 500 then return 14
	elseif self.level < 1000 then return 13
	elseif self.level < 1500 then return 10
	else return 8 end
end

function Survival2020Game:getTotalDelay()
		if self.level < 500 then return 60
	elseif self.level < 600 then return 45  -- lock delay: 13
	elseif self.level < 700 then return 36
	elseif self.level < 800 then return 27
	elseif self.level < 900 then return 21
	elseif self.level < 1000 then return 15
	elseif self.level < 1100 then return 36  -- lock delay: 10
	elseif self.level < 1200 then return 27
	elseif self.level < 1300 then return 21
	elseif self.level < 1400 then return 15
	elseif self.level < 1500 then return 12
	elseif self.level < 1600 then return 30  -- lock delay: 8
	elseif self.level < 1700 then return 21
	elseif self.level < 1800 then return 15
	elseif self.level < 1900 then return 12
	elseif self.level < 2020 then return 10
	else return 30 end
end

function Survival2020Game:getGravity()
	return 20
end

function Survival2020Game:getSkin()
	return self.level >= 1000 and "bone" or "2tie"
end

function Survival2020Game:hitTorikan(old_level, new_level)
	if old_level < 500 and new_level >= 500 and self.frames > frameTime(3,00) then
		self.level = 500
		return true
	end
	if old_level < 1000 and new_level >= 1000 and self.frames > frameTime(5,00) then
		self.level = 1000
		return true
	end
	if old_level < 1500 and new_level >= 1500 and self.frames > frameTime(7,00) then
		self.level = 1500
		return true
	end
	return false
end

function Survival2020Game:advanceOneFrame()
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
		if self.piece ~= nil then
			self.total_delay = self.total_delay + 1
			if self.total_delay >= self:getTotalDelay() then
				self.piece:dropToBottom(self.grid)
				self.piece.locked = true
			end
		end
	end
	return true
end

function Survival2020Game:onPieceEnter()
	if not self.clear and (
		(self.level < 1900 and self.level % 100 ~= 99) or
		(1900 <= self.level and self.level < 2019)
	) then
		self.level = self.level + 1
	end
	self.total_delay = 0
end

local cleared_row_levels = {1, 2, 4, 6}
local cleared_row_points = {0.02, 0.05, 0.15, 0.6}

function Survival2020Game:onLineClear(cleared_row_count)
	if not self.clear then
		local new_level = self.level + cleared_row_levels[cleared_row_count]
		self:updateSectionTimes(self.level, new_level)
		if new_level >= 2020 or self:hitTorikan(self.level, new_level) then
			if new_level >= 2020 then
				self.level = 2020
			end
			self.clear = true
			self.grid:clear()
			self.roll_frames = -150
		else
			self.level = math.min(new_level, 2020)
		end
	end
end

function Survival2020Game:updateScore(level, drop_bonus, cleared_lines)
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

function Survival2020Game:updateSectionTimes(old_level, new_level)
	if math.floor(old_level / 100) < math.floor(new_level / 100) then
		local section = math.floor(old_level / 100) + 1
		local section_time = self.frames - self.section_start_time
		table.insert(self.section_times, section_time)
		self.section_start_time = self.frames
		if section_time <= frameTime(0,30) then
			self.grade = self.grade + 2
		else
			self.grade = self.grade + 1
		end
	end
end

Survival2020Game.opacityFunction = function(age)
	if age > 300 then return 0
	else return 1 - math.max(age - 240, 0) / 60 end
end

function Survival2020Game:drawGrid()
	if self.level < 1500 then
		self.grid:draw()
	else
		self.grid:drawInvisible(self.opacityFunction)
	end
end

local function getLetterGrade(grade)
	if grade == 0 then
		return "1"
	elseif grade <= 9 then
		return "S" .. tostring(grade)
	else
		return "M" .. tostring(grade - 9)
	end
end

function Survival2020Game:getEndOfSectionForSection(section)
	if section == 21 then
		return 2020
	else
		return section * 100
	end
end

function Survival2020Game:drawScoringInfo()
	Survival2020Game.super.drawScoringInfo(self)

	love.graphics.setColor(1, 1, 1, 1)

	local text_x = config["side_next"] and 320 or 240

	love.graphics.setFont(font_3x5_2)
	love.graphics.printf("GRADE", text_x, 120, 40, "left")
	love.graphics.printf("SCORE", text_x, 200, 40, "left")
	love.graphics.printf("LEVEL", text_x, 320, 40, "left")

	local current_section = math.floor(self.level / 100) + 1
	self:drawSectionTimesWithSplits(current_section)

	love.graphics.setFont(font_3x5_3)
	love.graphics.printf(getLetterGrade(math.floor(self.grade)), text_x, 140, 90, "left")
	love.graphics.printf(self.score, text_x, 220, 90, "left")
	love.graphics.printf(self.level, text_x, 340, 50, "right")
	if self.clear then
		love.graphics.printf(self.level, text_x, 370, 50, "right")
	else
		love.graphics.printf(self:getEndOfSectionForSection(current_section), text_x, 370, 50, "right")
	end
end

function Survival2020Game:getBackground()
	return math.min(19, math.floor(self.level / 100))
end

function Survival2020Game:getHighscoreData()
	return {
		level = self.level,
		frames = self.frames,
		grade = self.grade,
	}
end

return Survival2020Game
