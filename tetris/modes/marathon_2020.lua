require 'funcs'

local GameMode = require 'tetris.modes.gamemode'
local Piece = require 'tetris.components.piece'

local History6RollsRandomizer = require 'tetris.randomizers.history_6rolls'

local Marathon2020Game = GameMode:extend()

Marathon2020Game.name = "Marathon 2020"
Marathon2020Game.hash = "Marathon2020"
Marathon2020Game.tagline = "2020 levels of pure pain! Can you achieve the World Master rank?"

function Marathon2020Game:new()
	Marathon2020Game.super:new()
	
	self.lock_drop = true
	self.lock_hard_drop = true
	self.enable_hold = true
	self.next_queue_length = 3

	self.delay_level = 0
	self.roll_frames = 0
	self.no_roll_frames = 0
	self.combo = 1
	self.randomizer = History6RollsRandomizer()
	self.section_cool_count = 0
	self.section_status = { [0] = "none" }
	self.torikan_passed = {
		[500] = false, [900] = false,
		[1000] = false, [1500] = false, [1900] = false
	}
	self.torikan_hit = false
	
	self.grade = 0
	self.grade_points = 0
	self.grade_point_decay_counter = 0
	self.max_grade_points = 0

	self.cool_timer = 0
end

function Marathon2020Game:getARE()
		if self.delay_level < 1 then return 27
	elseif self.delay_level < 2 then return 24
	elseif self.delay_level < 3 then return 21
	elseif self.delay_level < 4 then return 18
	elseif self.delay_level < 5 then return 16
	elseif self.delay_level < 6 then return 14
	elseif self.delay_level < 7 then return 12
	elseif self.delay_level < 8 then return 10
	elseif self.delay_level < 9 then return 8
	elseif self.delay_level < 13 then return 6
	elseif self.delay_level < 15 then return 5
	else return 4 end
end

function Marathon2020Game:getLineARE()
	return self:getARE()
end

function Marathon2020Game:getDasLimit()
		if self.delay_level < 1 then return 15
	elseif self.delay_level < 3 then return 12
	elseif self.delay_level < 5 then return 9
	elseif self.delay_level < 8 then return 8
	elseif self.delay_level < 10 then return 7
	elseif self.delay_level < 13 then return 6
	elseif self.delay_level < 15 then return 5
	elseif self.delay_level < 20 then return 4
	else return 3 end
end

function Marathon2020Game:getLineClearDelay()
		if self.delay_level < 1 then return 40
	elseif self.delay_level < 3 then return 25
	elseif self.delay_level < 4 then return 20
	elseif self.delay_level < 5 then return 15
	elseif self.delay_level < 7 then return 12
	elseif self.delay_level < 9 then return 8
	elseif self.delay_level < 11 then return 6
	elseif self.delay_level < 14 then return 4
	else return 2 end
end

function Marathon2020Game:getLockDelay()
		if self.delay_level < 6 then return 30
	elseif self.delay_level < 7 then return 26
	elseif self.delay_level < 8 then return 22
	elseif self.delay_level < 9 then return 19
	elseif self.delay_level < 10 then return 17
	elseif self.delay_level < 16 then return 15
	elseif self.delay_level < 17 then return 13
	elseif self.delay_level < 18 then return 11
	elseif self.delay_level < 19 then return 10
	elseif self.delay_level < 20 then return 9
	else return 8 end
end

function Marathon2020Game:getGravity()
		if self.level < 30  then return 4/256
	elseif self.level < 35  then return 6/256
	elseif self.level < 40  then return 8/256
	elseif self.level < 50  then return 10/256
	elseif self.level < 60  then return 12/256
	elseif self.level < 70  then return 16/256
	elseif self.level < 80  then return 32/256
	elseif self.level < 90  then return 48/256
	elseif self.level < 100 then return 64/256
	elseif self.level < 120 then return 80/256
	elseif self.level < 140 then return 96/256
	elseif self.level < 160 then return 112/256
	elseif self.level < 170 then return 128/256
	elseif self.level < 200 then return 144/256
	elseif self.level < 220 then return 4/256
	elseif self.level < 230 then return 32/256
	elseif self.level < 233 then return 64/256
	elseif self.level < 236 then return 96/256
	elseif self.level < 239 then return 128/256
	elseif self.level < 243 then return 160/256
	elseif self.level < 247 then return 192/256
	elseif self.level < 251 then return 224/256
	elseif self.level < 300 then return 1
	elseif self.level < 330 then return 2
	elseif self.level < 360 then return 3
	elseif self.level < 400 then return 4
	elseif self.level < 420 then return 5
	elseif self.level < 450 then return 4
	elseif self.level < 500 then return 3
	else return 20 end
end

local cleared_row_levels = {1, 2, 4, 6}

function Marathon2020Game:advanceOneFrame()
	if self.torikan_hit then
		self.no_roll_frames = self.no_roll_frames + 1
		if self.no_roll_frames > 120 then
			self.completed = true
		end
		return false
	elseif self.clear then
		self.roll_frames = self.roll_frames + 1
		if self.roll_frames < 0 then
			return false
		elseif self.roll_frames > 4000 then
			if self:qualifiesForMRoll() then self.grade = 31 end
			self.completed = true
		end
	elseif self.ready_frames == 0 then
		self.frames = self.frames + 1
	end
	return true
end

local cool_cutoffs = {
	[0] = frameTime(0,45,00),
	frameTime(0,41,50), frameTime(0,38,50), frameTime(0,35,00), frameTime(0,32,50), frameTime(0,29,20),
	frameTime(0,27,20), frameTime(0,24,80), frameTime(0,22,80), frameTime(0,20,60), frameTime(0,19,60),
	frameTime(0,19,40), frameTime(0,19,40), frameTime(0,18,40), frameTime(0,18,20), frameTime(0,16,20),
	frameTime(0,16,20), frameTime(0,16,20), frameTime(0,16,20), frameTime(0,16,20), frameTime(0,15,20)
}

local levels_for_cleared_rows = { 1, 2, 4, 6 }

function Marathon2020Game:onPieceEnter()
	self:updateLevel(1, false)
end

function Marathon2020Game:whilePieceActive()
	if not self.clear then
		self.grade_point_decay_counter = self.grade_point_decay_counter + self.grade + 2
	end
	if self.grade_point_decay_counter > 240 then
		self.grade_point_decay_counter = 0
		self.grade_points = math.max(0, self.grade_points - 1)
	end
end

function Marathon2020Game:onLineClear(cleared_row_count)
	self:updateLevel(levels_for_cleared_rows[cleared_row_count], true)
	self:updateGrade(cleared_row_count)
end

function Marathon2020Game:updateLevel(increment, line_clear)
	local new_level
	if self.torikan_passed[900] == false then
		if line_clear == false and (
			math.floor((self.level + increment) / 100) > math.floor(self.level / 100) or
			self.level == 998
		) then
			new_level = math.min(998, self.level + (99 - self.level % 100))
		else
			new_level = math.min(999, self.level + increment)
		end
	elseif self.torikan_passed[1900] == false then
		if line_clear == false and (
			math.floor((self.level + increment) / 100) > math.floor(self.level / 100) or
			self.level == 1999
		) then
			new_level = math.min(1999, self.level + (99 - self.level % 100))
		else
			new_level = math.min(2000, self.level + increment)
		end
	else
		if line_clear == false and (
			self.level < 1900 and
			math.floor((self.level + increment) / 100) > math.floor(self.level / 100)
		) then
			new_level = self.level + (99 - self.level % 100)
		elseif line_clear == false and self.level + increment > 2019 then
			new_level = 2019
		else
			new_level = math.min(2020, self.level + increment)
		end
	end
	if not self.clear then
		self:updateSectionTimes(self.level, new_level)
		if not self.clear then
			self.level = new_level
		end
	end
end

local low_cleared_line_points = {10, 20, 30, 40}
local mid_cleared_line_points = {2, 6, 12, 24}
local high_cleared_line_points = {1, 4, 9, 20}

local function getGradeForGradePoints(points)
	return math.min(30, math.floor(math.sqrt((points / 50) * 8 + 1) / 2 - 0.5))
	-- Don't be afraid of the above function. All it does is make it so that
	-- you need 50 points to get to grade 1, 100 points to grade 2, etc.
end

function Marathon2020Game:updateGrade(cleared_lines)
	-- update grade points and max grade points
	if self.clear then return end
	local point_level = math.floor(self.level / 100) + self.delay_level
	local plus_points = math.max(
		low_cleared_line_points[cleared_lines],
		mid_cleared_line_points[cleared_lines] * (1 + point_level / 2),
		high_cleared_line_points[cleared_lines] * (point_level - 2),
		(self.level >= 1000 and cleared_lines == 4) and self.grade * 30 or 0
	)
	self.grade_points = self.grade_points + plus_points
	if self.grade_points > self.max_grade_points then
		self.max_grade_points = self.grade_points
	end
	self.grade = getGradeForGradePoints(self.max_grade_points)
end

function Marathon2020Game:getTotalGrade()
	return self.grade + self.section_cool_count
end

local function getSectionForLevel(level)
	if level < 2000 then
		return math.floor(level / 100) + 1
	elseif level < 2020 then
		return 20
	else
		return 21
	end
end

function Marathon2020Game:getEndOfSectionForSection(section)
		if self.torikan_passed[900] == false and section == 10 then return 999
	elseif self.torikan_passed[1900] == false and section == 20 then return 2000
	elseif section == 20 then return 2020
	else return section * 100 end
end

function Marathon2020Game:sectionPassed(old_level, new_level)
	if self.torikan_passed[900] == false then
		return (
			(math.floor(old_level / 100) < math.floor(new_level / 100)) or
			(new_level >= 999)
		)
	elseif self.torikan_passed[1900] == false then
		return (
			(math.floor(old_level / 100) < math.floor(new_level / 100)) or
			(new_level >= 2000)
		)
	else
		return (
			(new_level < 2000 and math.floor(old_level / 100) < math.floor(new_level / 100)) or
			(new_level >= 2020)
		)
	end
end

function Marathon2020Game:checkTorikan(section)
	if section == 5 and self.frames < frameTime(8,00,00) then self.torikan_passed[500] = true end
	if section == 9 and self.frames < frameTime(10,30,00) then self.torikan_passed[900] = true end
	if section == 10 and self.frames < frameTime(10,45,00) then self.torikan_passed[1000] = true end
	if section == 15 and self.frames < frameTime(12,30,00) then self.torikan_passed[1500] = true end
	if section == 19 and self.frames < frameTime(13,15,00) then self.torikan_passed[1900] = true end
end

function Marathon2020Game:checkClear(level)
	if (
		self.torikan_passed[500] == false and level >= 500 or
		self.torikan_passed[900] == false and level >= 999 or
		self.torikan_passed[1000] == false and level >= 1000 or
		self.torikan_passed[1500] == false and level >= 1500 or
		self.torikan_passed[1900] == false and level >= 2000 or
		level >= 2020
	) then

			if self.torikan_passed[500] == false then self.level = 500
		elseif self.torikan_passed[900] == false then self.level = 999
		elseif self.torikan_passed[1000] == false then self.level = 1000
		elseif self.torikan_passed[1500] == false then self.level = 1500
		elseif self.torikan_passed[1900] == false then self.level = 2000
		else self.level = 2020 end

		self.clear = true
		self.grid:clear()
		if (
			self.torikan_passed[900] == false and level >= 999 or
			level >= 2020
		) then
			self.roll_frames = -150
		else
			self.torikan_hit = true
			self.no_roll_frames = -150
		end
	end
end

function Marathon2020Game:updateSectionTimes(old_level, new_level)
	local function sectionCool(section)
		self.section_cool_count = self.section_cool_count + 1
		if section <= 10 then
			self.delay_level = math.min(20, self.delay_level + 1)
		end
		table.insert(self.section_status, "cool")
		self.cool_timer = 300
	end

	local section = getSectionForLevel(old_level)

	if old_level % 100 < 70 and new_level >= math.floor(old_level / 100) * 100 + 70 then
		-- record section 70 time
		section_70_time = self.frames - self.section_start_time
		table.insert(self.secondary_section_times, section_70_time)
	end

	if self:sectionPassed(old_level, new_level) then
		-- record new section
		section_time = self.frames - self.section_start_time
		table.insert(self.section_times, section_time)
		self.section_start_time = self.frames

		if (
			(self.secondary_section_times[section] < cool_cutoffs[self.delay_level]) and
		  	(section == 1 or self.secondary_section_times[section] <= self.secondary_section_times[section - 1] + 120)
		) then
			sectionCool(section)
		else
			table.insert(self.section_status, "none")
		end

		if section > 5 then
			self.delay_level = math.min(20, self.delay_level + 1)
		end
		self:checkTorikan(section)
		self:checkClear(new_level)
	end
end

function Marathon2020Game:updateScore(level, drop_bonus, cleared_lines)
	if cleared_lines > 0 then
		self.score = self.score + (
			(math.ceil((level + cleared_lines) / 4) + drop_bonus) *
			cleared_lines * (cleared_lines * 2 - 1) * (self.combo * 2 - 1)
		)
		self.lines = self.lines + cleared_lines
		self.combo = self.combo + cleared_lines - 1
	else
		self.drop_bonus = 0
		self.combo = 1
	end
end

Marathon2020Game.rollOpacityFunction = function(age)
	if age > 300 then return 0
	elseif age < 240 then return 1
	else return (300 - age) / 60 end
end

Marathon2020Game.mRollOpacityFunction = function(age)
	if age > 4 then return 0
	else return 1 - age / 4 end
end

function Marathon2020Game:qualifiesForMRoll()
--[[

GM-roll requirements

You qualify for the GM roll if you:
- Reach level 2020
- with a grade of 50
- and at least 25,000 grade points
- in less than 13:30.00 total.

]]--
	
	return self.level >= 2020 and self:getTotalGrade() == 50 and self.grade_points >= 25000 and self.frames <= frameTime(13,30)
end

function Marathon2020Game:drawGrid()
	if self.clear and not (self.completed or self.game_over) then
		if self:qualifiesForMRoll() then
			self.grid:drawInvisible(self.mRollOpacityFunction)
		else
			self.grid:drawInvisible(self.rollOpacityFunction)
		end
	else
		self.grid:draw()
		if self.piece ~= nil and self.level < 100 then
			self:drawGhostPiece()
		end
	end
end

function Marathon2020Game:sectionColourFunction(section)
	if self.section_status[section] == "cool" then
		return { 0, 1, 0, 1 }
	else
		return { 1, 1, 1, 1 }
	end
end

function Marathon2020Game:drawScoringInfo()
	Marathon2020Game.super.drawScoringInfo(self)

	local current_section = getSectionForLevel(self.level)
	local text_x = config["side_next"] and 320 or 240

	love.graphics.setFont(font_3x5_2)
	love.graphics.printf("GRADE", text_x, 100, 40, "left")
	love.graphics.printf("GRADE PTS.", text_x, 200, 90, "left")
	love.graphics.printf("LEVEL", text_x, 320, 40, "left")

	self:drawSectionTimesWithSecondary(current_section, 20)

	if (self.cool_timer > 0) then
				love.graphics.printf("COOL!!", 64, 400, 160, "center")
				self.cool_timer = self.cool_timer - 1
		end	

	love.graphics.setFont(font_3x5_3)
	
	local grade = self:getTotalGrade()
	love.graphics.printf(
		grade > 50 and "GM" or grade,
		text_x, 120, 90, "left"
	)

	love.graphics.printf(self.grade_points, text_x, 220, 90, "left")
	love.graphics.printf(self.level, text_x, 340, 50, "right")

	if self.clear then
		love.graphics.printf(self.level, text_x, 370, 50, "right")
	else
		love.graphics.printf(self:getEndOfSectionForSection(current_section), text_x, 370, 50, "right")
	end

end

function Marathon2020Game:getHighscoreData()
	return {
		grade = self:getTotalGrade(),
		level = self.level,
		frames = self.frames,
	}
end

function Marathon2020Game:getBackground()
	return math.min(19, math.floor(self.level / 100))
end

return Marathon2020Game
