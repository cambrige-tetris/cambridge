require 'funcs'

local GameMode = require 'tetris.modes.gamemode'
local Piece = require 'tetris.components.piece'

local Bag7NoSZOStartRandomizer = require 'tetris.randomizers.bag7noSZOstart'

local SurvivalAXGame = GameMode:extend()

SurvivalAXGame.name = "Survival AX"
SurvivalAXGame.hash = "SurvivalAX"
SurvivalAXGame.tagline = "Can you clear the time hurdles when the game goes this fast?"


function SurvivalAXGame:new()
	SurvivalAXGame.super:new()

	self.randomizer = Bag7NoSZOStartRandomizer()

	self.section_time_limit = 3600
	self.section_start_time = 0
	self.section_times = { [0] = 0 }
	self.section_clear = false

	self.lock_drop = true
	self.lock_hard_drop = true
	self.enable_hold = true
	self.next_queue_length = 3
end

function SurvivalAXGame:getARE()
		if self.lines < 10 then return 18
	elseif self.lines < 40 then return 14
	elseif self.lines < 60 then return 12
	elseif self.lines < 70 then return 10
	elseif self.lines < 80 then return 8
	elseif self.lines < 90 then return 7
	else return 6 end
end

function SurvivalAXGame:getLineARE()
	return self:getARE()
end

function SurvivalAXGame:getDasLimit()
		if self.lines < 20 then return 10
	elseif self.lines < 50 then return 9
	elseif self.lines < 70 then return 8
	else return 7 end
end

function SurvivalAXGame:getLineClearDelay()
		if self.lines < 10 then return 14
	elseif self.lines < 30 then return 9
	else return 5 end
end

function SurvivalAXGame:getLockDelay()
		if self.lines < 10 then return 28
	elseif self.lines < 20 then return 24
	elseif self.lines < 30 then return 22
	elseif self.lines < 40 then return 20
	elseif self.lines < 50 then return 18
	elseif self.lines < 70 then return 14
	else return 13 end
end

function SurvivalAXGame:getGravity()
	return 20
end

function SurvivalAXGame:getSection()
	return math.floor(self.level / 100) + 1
end

function SurvivalAXGame:advanceOneFrame()
	if self.ready_frames == 0 then
		if not self.section_clear then
			self.frames = self.frames + 1
		end
		if self:getSectionTime() >= self.section_time_limit then
			self.game_over = true
		end
	end
	return true
end

function SurvivalAXGame:onLineClear(cleared_row_count)
	if not self.clear then
		local new_lines = self.lines + cleared_row_count
		self:updateSectionTimes(self.lines, new_lines)
		self.lines = math.min(new_lines, 150)
		if self.lines == 150 then
			self.grid:clear()
			self.clear = true
			self.completed = true
		end
	end
end

function SurvivalAXGame:getSectionTime()
	return self.frames - self.section_start_time
end

function SurvivalAXGame:updateSectionTimes(old_lines, new_lines)
	if math.floor(old_lines / 10) < math.floor(new_lines / 10) then
		-- record new section
		table.insert(self.section_times, self:getSectionTime())
		self.section_start_time = self.frames
		self.section_clear = true
	end
end

function SurvivalAXGame:onPieceEnter()
	self.section_clear = false
end

function SurvivalAXGame:drawGrid(ruleset)
	self.grid:draw()
end

function SurvivalAXGame:getHighscoreData()
	return {
		lines = self.lines,
		frames = self.frames,
	}
end

function SurvivalAXGame:drawScoringInfo()
	SurvivalAXGame.super.drawScoringInfo(self)

	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.setFont(font_3x5)
	love.graphics.print(
		self.das.direction .. " " ..
		self.das.frames .. " " ..
		strTrueValues(self.prev_inputs)
	)

	love.graphics.setFont(font_3x5_2)
	love.graphics.printf("NEXT", 64, 40, 40, "left")
	if self.lines < 150 then love.graphics.printf("TIME LEFT", 240, 250, 80, "left") end
	love.graphics.printf("LINES", 240, 320, 40, "left")

	local current_section = math.floor(self.lines / 10) + 1
	self:drawSectionTimesWithSplits(current_section)

	love.graphics.setFont(font_3x5_3)
	love.graphics.printf(self.lines, 240, 340, 40, "right")
	love.graphics.printf(self.clear and self.lines or self:getSectionEndLines(), 240, 370, 40, "right")

	-- draw time left, flash red if necessary
	local time_left = self.section_time_limit - math.max(self:getSectionTime(), 0)
	if not self.game_over and not self.clear and time_left < frameTime(0,10) and time_left % 4 < 2 then
		love.graphics.setColor(1, 0.3, 0.3, 1)
	end
	if self.lines < 150 then love.graphics.printf(formatTime(time_left), 240, 270, 160, "left") end
	love.graphics.setColor(1, 1, 1, 1)
end

function SurvivalAXGame:getSectionEndLines()
	return math.floor(self.lines / 10 + 1) * 10
end

function SurvivalAXGame:getBackground()
	return math.floor(self.lines / 10)
end

return SurvivalAXGame
