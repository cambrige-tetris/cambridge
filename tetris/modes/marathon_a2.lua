require 'funcs'

local GameMode = require 'tetris.modes.gamemode'
local Piece = require 'tetris.components.piece'

local History6RollsRandomizer = require 'tetris.randomizers.history_6rolls'

local MarathonA2Game = GameMode:extend()

MarathonA2Game.name = "Marathon A2"
MarathonA2Game.hash = "MarathonA2"
MarathonA2Game.tagline = "The points don't matter! Can you reach the invisible roll?"




function MarathonA2Game:new()
	MarathonA2Game.super:new()

	setTargetFPS(61.68)
	self.roll_frames = 0
	self.combo = 1
	self.grade_combo = 1
	self.randomizer = History6RollsRandomizer()
	self.grade = 0
	self.grade_points = 0
	self.grade_point_decay_counter = 0
	self.section_start_time = 0
	self.section_times = { [0] = 0 }
	self.section_tetrises = { [0] = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	self.tetris_count = 0

	self.SGnames = {
		"9", "8", "7", "6", "5", "4", "3", "2", "1",
		"S1", "S2", "S3", "S4", "S5", "S6", "S7", "S8", "S9",
		"GM"
	}

	self.additive_gravity = false
	self.lock_drop = false
	self.lock_hard_drop = false
	self.enable_hold = false
	self.next_queue_length = 1
end

function MarathonA2Game:onExit()
	setTargetFPS(60)
end

function MarathonA2Game:getARE()
		if self.level < 700 then return 27
	elseif self.level < 800 then return 18
	else return 14 end
end

function MarathonA2Game:getLineARE()
		if self.level < 600 then return 27
	elseif self.level < 700 then return 18
	elseif self.level < 800 then return 14
	else return 8 end
end

function MarathonA2Game:getDasLimit()
		if self.level < 500 then return 15
	elseif self.level < 900 then return 9
	else return 7 end
end

function MarathonA2Game:getLineClearDelay()
		if self.level < 500 then return 40
	elseif self.level < 600 then return 25
	elseif self.level < 700 then return 16
	elseif self.level < 800 then return 12
	else return 6 end
end

function MarathonA2Game:getLockDelay()
		if self.level < 900 then return 30
	else return 17 end
end

function MarathonA2Game:getGravity()
		if (self.level < 30)  then return 4/256
	elseif (self.level < 35)  then return 6/256
	elseif (self.level < 40)  then return 8/256
	elseif (self.level < 50)  then return 10/256
	elseif (self.level < 60)  then return 12/256
	elseif (self.level < 70)  then return 16/256
	elseif (self.level < 80)  then return 32/256
	elseif (self.level < 90)  then return 48/256
	elseif (self.level < 100) then return 64/256
	elseif (self.level < 120) then return 80/256
	elseif (self.level < 140) then return 96/256
	elseif (self.level < 160) then return 112/256
	elseif (self.level < 170) then return 128/256
	elseif (self.level < 200) then return 144/256
	elseif (self.level < 220) then return 4/256
	elseif (self.level < 230) then return 32/256
	elseif (self.level < 233) then return 64/256
	elseif (self.level < 236) then return 96/256
	elseif (self.level < 239) then return 128/256
	elseif (self.level < 243) then return 160/256
	elseif (self.level < 247) then return 192/256
	elseif (self.level < 251) then return 224/256
	elseif (self.level < 300) then return 1
	elseif (self.level < 330) then return 2
	elseif (self.level < 360) then return 3
	elseif (self.level < 400) then return 4
	elseif (self.level < 420) then return 5
	elseif (self.level < 450) then return 4
	elseif (self.level < 500) then return 3
	else return 20
	end
end

function MarathonA2Game:advanceOneFrame()
	if self.clear then
		self.roll_frames = self.roll_frames + 1
		if self.roll_frames < 0 then return false end
		if self.roll_frames > 3701 then
			self.completed = true
			if self.grade == 32 then
				self.grade = 33
			end
		end
	elseif self.ready_frames == 0 then
		self.frames = self.frames + 1
	end
	return true
end

function MarathonA2Game:onPieceEnter()
	if (self.level % 100 ~= 99 and self.level ~= 998) and not self.clear and self.frames ~= 0 then
		self.level = self.level + 1
	end
end

function MarathonA2Game:updateScore(level, drop_bonus, cleared_lines)
	if not self.clear then
		self:updateGrade(cleared_lines)
		if cleared_lines >= 4 then
			self.tetris_count = self.tetris_count + 1
		end
		if self.grid:checkForBravo(cleared_lines) then
			self.bravo = 4
		else
			self.bravo = 1
		end
		if cleared_lines > 0 then
			self.combo = self.combo + (cleared_lines - 1) * 2
			if cleared_lines > 1 then
				self.grade_combo = self.grade_combo + 1
			end
			self.score = self.score + (
				(math.ceil((level + cleared_lines) / 4) + drop_bonus) *
				cleared_lines * self.combo * self.bravo
			)
		else
			self.combo = 1
			self.grade_combo = 1
		end
		self.drop_bonus = 0
	else self.lines = self.lines + cleared_lines end
end

function MarathonA2Game:onLineClear(cleared_row_count)
	self:updateSectionTimes(self.level, self.level + cleared_row_count)
	self.level = math.min(self.level + cleared_row_count, 999)
	if self.level == 999 and not self.clear then
		self.clear = true
		self.grid:clear()
		if self:qualifiesForMRoll() then self.grade = 32 end
		self.roll_frames = -150
	end
	self.lock_drop = self.level >= 900
	self.lock_hard_drop = self.level >= 900
end

function MarathonA2Game:updateSectionTimes(old_level, new_level)
	if self.clear then return end
	if math.floor(old_level / 100) < math.floor(new_level / 100) or
	new_level >= 999 then
		-- record new section
		local section_time = self.frames - self.section_start_time
		self.section_times[math.floor(old_level / 100)] = section_time
		self.section_start_time = self.frames
		self.section_tetrises[math.floor(old_level / 100)] = self.tetris_count
		self.tetris_count = 0
	end
end

local grade_point_bonuses = {
	{10, 20, 40, 50},
	{10, 20, 30, 40},
	{10, 20, 30, 40},
	{10, 15, 30, 40},
	{10, 15, 20, 40},
	{5, 15, 20, 30},
	{5, 10, 20, 30},
	{5, 10, 15, 30},
	{5, 10, 15, 30},
	{5, 10, 15, 30},
	{2, 12, 13, 30},
	{2, 12, 13, 30},
	{2, 12, 13, 30},
	{2, 12, 13, 30},
	{2, 12, 13, 30},
	{2, 12, 13, 30},
	{2, 12, 13, 30},
	{2, 12, 13, 30},
	{2, 12, 13, 30},
	{2, 12, 13, 30},
	{2, 12, 13, 30},
	{2, 12, 13, 30},
	{2, 12, 13, 30},
	{2, 12, 13, 30},
	{2, 12, 13, 30},
	{2, 12, 13, 30},
	{2, 12, 13, 30},
	{2, 12, 13, 30},
	{2, 12, 13, 30},
	{2, 12, 13, 30},
	{2, 12, 13, 30},
	{2, 12, 13, 30},
}

local grade_point_decays = {
	125, 80, 80, 50, 45, 45, 45,
	40, 40, 40, 40, 40, 30, 30, 30,
	20, 20, 20, 20, 20,
	15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
	10, 10, 10
}

local combo_multipliers = {
	{1.0, 1.0, 1.0, 1.0},
	{1.2, 1.4, 1.5, 1.0},
	{1.2, 1.5, 1.8, 1.0},
	{1.4, 1.6, 2.0, 1.0},
	{1.4, 1.7, 2.2, 1.0},
	{1.4, 1.8, 2.3, 1.0},
	{1.4, 1.9, 2.4, 1.0},
	{1.5, 2.0, 2.5, 1.0},
	{1.5, 2.1, 2.6, 1.0},
	{2.0, 2.5, 3.0, 1.0},
}

local grade_conversion = {
	[0] = 0,
	1, 2, 3, 4, 5, 5, 6, 6, 7, 7,
	7, 8, 8, 8, 9, 9, 9, 10, 11, 12,
	12, 12, 13, 13, 14, 14, 15, 15, 16, 16,
	17, 18, 19
}

function MarathonA2Game:whilePieceActive()
	if self.clear then return
	else
		self.grade_point_decay_counter = self.grade_point_decay_counter + 1
		if self.grade_point_decay_counter >= grade_point_decays[self.grade + 1] then
			self.grade_point_decay_counter = 0
			self.grade_points = math.max(0, self.grade_points - 1)
		end
	end
end

function MarathonA2Game:updateGrade(cleared_lines)
	if self.clear or cleared_lines == 0 then return
	else
		self.grade_points = self.grade_points + (
			math.ceil(
				grade_point_bonuses[self.grade + 1][cleared_lines] *
				combo_multipliers[math.min(self.grade_combo, 10)][cleared_lines]
			) * (1 + math.floor(self.level / 250))
		)
		if self.grade_points >= 100 and self.grade < 31 then
			self.grade_points = 0
			self.grade = self.grade + 1
		end
	end
end

local tetris_requirements = { [0] = 2, 2, 2, 2, 2, 1, 1, 1, 1, 0 }

function MarathonA2Game:qualifiesForMRoll()
	if not self.clear then return false end
	-- tetris requirements
	for section = 0, 9 do
		if self.section_tetrises[section] < tetris_requirements[section] then
			return false
		end
	end
	-- section time requirements
	local section_average = 0
	for section = 0, 4 do
		section_average = section_average + self.section_times[section]
		if self.section_times[section] > frameTime(1,05) then
			return false
		end
	end
	-- section time average requirements
	if self.section_times[5] > section_average / 5 then
		return false
	end
	for section = 6, 9 do
		if self.section_times[section] > self.section_times[section - 1] + 120 then
			return false
		end
	end
	if self.grade < 31 or self.frames > frameTime(8,45) then
		return false
	end
	return true
end

function MarathonA2Game:getLetterGrade()
	local grade = grade_conversion[self.grade]
	if grade < 9 then
		return tostring(9 - grade)
	elseif grade < 18 then
		return "S" .. tostring(grade - 8)
	elseif grade == 18 then
		return "M"
	else
		return "GM"
	end
end

MarathonA2Game.rollOpacityFunction = function(age)
	if age < 240 then return 1
	elseif age > 300 then return 0
	else return 1 - (age - 240) / 60 end
end

MarathonA2Game.mRollOpacityFunction = function(age)
	if age > 4 then return 0
	else return 1 - age / 4 end
end

function MarathonA2Game:drawGrid()
	if self.clear and not (self.completed or self.game_over) then
		if self:qualifiesForMRoll() then
			self.grid:drawInvisible(self.mRollOpacityFunction, nil, false)
		else
			self.grid:drawInvisible(self.rollOpacityFunction, nil, false)
		end
	else
		self.grid:draw()
		if self.piece ~= nil and self.level < 100 then
			self:drawGhostPiece()
		end
	end
end

function MarathonA2Game:drawScoringInfo()
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
	love.graphics.printf("LEVEL", 240, 320, 40, "left")
	local sg = self.grid:checkSecretGrade()
	if sg >= 5 then
		love.graphics.printf("SECRET GRADE", 240, 430, 180, "left")
	end

	love.graphics.setFont(font_3x5_3)
	if self.clear then
		if self:qualifiesForMRoll() then
			if self.lines >= 32 and self.roll_frames > 3701 then love.graphics.setColor(1, 0.5, 0, 1)
			else love.graphics.setColor(0, 1, 0, 1) end
		else
			if self.roll_frames > 3701 then love.graphics.setColor(1, 0.5, 0, 1)
			else love.graphics.setColor(0, 1, 0, 1) end
		end
	end
	love.graphics.printf(self:getLetterGrade(), 240, 140, 90, "left")
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.printf(self.score, 240, 220, 90, "left")
	love.graphics.printf(self.level, 240, 340, 40, "right")
	love.graphics.printf(self:getSectionEndLevel(), 240, 370, 40, "right")
	if sg >= 5 then
		love.graphics.printf(self.SGnames[sg], 240, 450, 180, "left")
	end

	love.graphics.setFont(font_8x11)
	love.graphics.printf(formatTime(self.frames), 64, 420, 160, "center")
end

function MarathonA2Game:getHighscoreData()
	return {
		grade = grade_conversion[self.grade],
		score = self.score,
		level = self.level,
		frames = self.frames,
	}
end

function MarathonA2Game:getSectionEndLevel()
	if self.level >= 900 then return 999
	else return math.floor(self.level / 100 + 1) * 100 end
end

function MarathonA2Game:getBackground()
	return math.floor(self.level / 100)
end

return MarathonA2Game
