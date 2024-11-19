require 'funcs'

local GameMode = require 'tetris.modes.gamemode'
local Piece = require 'tetris.components.piece'

local History6RollsRandomizer = require 'tetris.randomizers.history_6rolls_35bag'

local PhantomMania2Game = GameMode:extend()

PhantomMania2Game.name = "Phantom Mania 2"
PhantomMania2Game.hash = "PhantomMania2"
PhantomMania2Game.tagline = "The blocks disappear even faster now! Can you make it to level 1300?"




function PhantomMania2Game:new(secret_inputs)
	PhantomMania2Game.super:new(secret_inputs)

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
	self.hold_age = 0
	self.queue_age = 0
	self.roll_points = 0

	self.SGnames = {
		"S1", "S2", "S3", "S4", "S5", "S6", "S7", "S8", "S9",
		"M1", "M2", "M3", "M4", "M5", "M6", "M7", "M8", "M9",
		"GM"
	}

	self.randomizer = History6RollsRandomizer()

	self.lock_drop = true
	self.lock_hard_drop = true
	self.enable_hold = true
	self.next_queue_length = 3

	self.coolregret_message = ""
	self.coolregret_timer = 0
	self.coolregrets = { [0] = 0 }
end

function PhantomMania2Game:getARE()
		if self.level < 300 then return 12
	else return 6 end
end

function PhantomMania2Game:getLineARE()
		if self.level < 100 then return 8
	elseif self.level < 200 then return 7
	elseif self.level < 500 then return 6
	elseif self.level < 1300 then return 5
	else return 6 end
end

function PhantomMania2Game:getDasLimit()
		if self.level < 200 then return 9
	elseif self.level < 500 then return 7
	else return 5 end
end

function PhantomMania2Game:getLineClearDelay()
	return self:getLineARE() - 2
end

function PhantomMania2Game:getLockDelay()
		if self.level < 200 then return 18
	elseif self.level < 300 then return 17
	elseif self.level < 500 then return 15
	elseif self.level < 600 then return 13
	else return 12 end
end

function PhantomMania2Game:getGravity()
	return 20
end

function PhantomMania2Game:getGarbageLimit()
	if self.level < 600 then return 20
	elseif self.level < 700 then return 18
	elseif self.level < 800 then return 10
	elseif self.level < 900 then return 9
	else return 8 end
end

function PhantomMania2Game:getSkin()
	return self.level >= 1000 and "bone" or "2tie"
end

function PhantomMania2Game:hitTorikan(old_level, new_level)
	if old_level < 300 and new_level >= 300 and self.frames > frameTime(2,02) then
		self.level = 300
		return true
	end
	if old_level < 500 and new_level >= 500 and self.frames > frameTime(3,03) then
		self.level = 500
		return true
	end
	if old_level < 800 and new_level >= 800 and self.frames > frameTime(4,45) then
		self.level = 800
		return true
	end
	if old_level < 1000 and new_level >= 1000 and self.frames > frameTime(5,38) then
		self.level = 1000
		return true
	end
	return false
end

function PhantomMania2Game:advanceOneFrame()
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
			self.roll_points = self.level >= 1300 and self.roll_points + 150 or self.roll_points
			self.grade = self.grade + math.floor(self.roll_points / 100)
			self.completed = true
		end
	elseif self.ready_frames == 0 then
		self.frames = self.frames + 1
		self.hold_age = self.hold_age + 1
	end
	return true
end

function PhantomMania2Game:whilePieceActive()
	self.queue_age = self.queue_age + 1
end

function PhantomMania2Game:onPieceEnter()
	self.queue_age = 0
	if (self.level % 100 ~= 99) and not self.clear and self.frames ~= 0 then
		self.level = self.level + 1
	end
end

local cleared_row_levels = {1, 2, 4, 6}
local torikan_roll_points = {10, 20, 30, 100}
local big_roll_points = {10, 20, 100, 200}

function PhantomMania2Game:onLineClear(cleared_row_count)
	if not self.clear then
		local new_level = self.level + cleared_row_levels[cleared_row_count]
		self:updateSectionTimes(self.level, new_level)
		if new_level >= 1300 or self:hitTorikan(self.level, new_level) then
			if new_level >= 1300 then
				self.level = 1300
				self.big_mode = true
			end
			self.clear = true
			self.grid:clear()
			self.roll_frames = -150
		else
			self.level = math.min(new_level, 1300)
		end
		self:advanceBottomRow(-cleared_row_count)
	else
		if self.big_mode then self.roll_points = self.roll_points + big_roll_points[cleared_row_count / 2]
		else self.roll_points = self.roll_points + torikan_roll_points[cleared_row_count] end
		if self.roll_points >= 100 then
			self.roll_points = self.roll_points - 100
			self.grade = self.grade + 1
		end
	end
end

function PhantomMania2Game:onPieceLock(piece, cleared_row_count)
	self.super:onPieceLock()
	if cleared_row_count == 0 then self:advanceBottomRow(1) end
end

function PhantomMania2Game:onHold()
	self.super:onHold()
	self.hold_age = 0
end

function PhantomMania2Game:updateScore(level, drop_bonus, cleared_lines)
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


local cool_cutoffs = {
	frameTime(0,36), frameTime(0,36), frameTime(0,36), frameTime(0,36), frameTime(0,36),
	frameTime(0,30), frameTime(0,30), frameTime(0,30), frameTime(0,30), frameTime(0,30),
	frameTime(0,30), frameTime(0,30), frameTime(0,30),
}

local regret_cutoffs = {
	frameTime(0,50), frameTime(0,50), frameTime(0,50), frameTime(0,50), frameTime(0,50),
	frameTime(0,42), frameTime(0,42), frameTime(0,42), frameTime(0,42), frameTime(0,42),
	frameTime(0,42), frameTime(0,42), frameTime(0,42),
}

function PhantomMania2Game:updateSectionTimes(old_level, new_level)
	if math.floor(old_level / 100) < math.floor(new_level / 100) then
		local section = math.floor(old_level / 100) + 1
		local section_time = self.frames - self.section_start_time
		table.insert(self.section_times, section_time)
		self.section_start_time = self.frames
		if section_time <= cool_cutoffs[section] then
			self.grade = self.grade + 2
			table.insert(self.coolregrets, 2)
			self.coolregret_message = "COOL!!"
			self.coolregret_timer = 300
		elseif section_time <= regret_cutoffs[section] then
			self.grade = self.grade + 1
			table.insert(self.coolregrets, 1)
		else
			table.insert(self.coolregrets, 0)
			self.coolregret_message = "REGRET!!"
			self.coolregret_timer = 300
		end
	end
end

function PhantomMania2Game:advanceBottomRow(dx)
	if self.level >= 500 and self.level < 1000 then
		self.garbage = math.max(self.garbage + dx, 0)
		if self.garbage >= self:getGarbageLimit() then
			self.grid:copyBottomRow()
			self.garbage = 0
		end
	end
end

PhantomMania2Game.rollOpacityFunction = function(age)
	if age > 4 then return 0
	else return 1 - age / 4 end
end

PhantomMania2Game.garbageOpacityFunction = function(age)
	if age > 30 then return 0
	else return 1 - age / 30 end
end

function PhantomMania2Game:drawGrid()
	if not (self.game_over or self.completed or (self.clear and self.level < 1300)) then
		self.grid:drawInvisible(self.rollOpacityFunction, self.garbageOpacityFunction)
	else
		self.grid:draw()
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

function PhantomMania2Game:setNextOpacity(i)
	if self.level > 1000 and self.level < 1300 then
		local hidden_next_pieces = math.floor(self.level / 100) - 10
		if i < hidden_next_pieces then
			love.graphics.setColor(1, 1, 1, 0)
		elseif i == hidden_next_pieces then
			love.graphics.setColor(1, 1, 1, 1 - math.min(1, self.queue_age / 4))
		else
			love.graphics.setColor(1, 1, 1, 1)
		end
	else
		love.graphics.setColor(1, 1, 1, 1)
	end
end

function PhantomMania2Game:setHoldOpacity()
	if self.level > 1000 and self.level < 1300 then
		love.graphics.setColor(1, 1, 1, 1 - math.min(1, self.hold_age / 15))
	else
		local colour = self.held and 0.6 or 1
		love.graphics.setColor(colour, colour, colour, 1)
	end
end

function PhantomMania2Game:sectionColourFunction(section)
	if self.coolregrets[section] == 2 then
		return { 0, 1, 0, 1 }
	elseif self.coolregrets[section] == 0 then
		return { 1, 0, 0, 1 }
	else
		return { 1, 1, 1, 1 }
	end
end

function PhantomMania2Game:drawScoringInfo()
	PhantomMania2Game.super.drawScoringInfo(self)

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

	self:drawSectionTimesWithSplits(math.floor(self.level / 100) + 1)

	if(self.coolregret_timer > 0) then
				love.graphics.printf(self.coolregret_message, 64, 400, 160, "center")
				self.coolregret_timer = self.coolregret_timer - 1
		end

	love.graphics.setFont(font_3x5_3)
	love.graphics.printf(getLetterGrade(math.floor(self.grade)), text_x, 140, 90, "left")
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

function PhantomMania2Game:getBackground()
	return math.floor(self.level / 100)
end

function PhantomMania2Game:getHighscoreData()
	return {
		level = self.level,
		frames = self.frames,
		grade = self.grade,
	}
end

return PhantomMania2Game
