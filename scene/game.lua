local sha2 = require "libs.sha2"
local binser = require "libs.binser"
local GameScene = Scene:extend()

GameScene.title = "Game"

require 'load.save'

function GameScene:new(game_mode, ruleset, inputs)
	love.mouse.setVisible(true)
	self.retry_mode = game_mode
	self.retry_ruleset = ruleset
	self.secret_inputs = inputs
	self.sha_tbl = {mode = sha2.sha256(binser.s(game_mode)), ruleset = sha2.sha256(binser.s(ruleset))}
	self.game = game_mode(self.secret_inputs)
	self.game.secret_inputs = inputs
	self.ruleset = ruleset(self.game)
	self.game:initialize(self.ruleset)
	self.movement_queue = {}
	self.inputs = {
		left=false,
		right=false,
		up=false,
		down=false,
		rotate_left=false,
		rotate_left2=false,
		rotate_right=false,
		rotate_right2=false,
		rotate_180=false,
		hold=false,
	}
	self.paused = false
	self.game.pause_count = 0
	self.game.pause_time = 0
	self.game.pause_timestamps = {}
	self.frame_steps = 0
	DiscordRPC:update({
		details = self.game.rpc_details,
		state = self.game.name,
		largeImageKey = "ingame-"..self.game:getBackground().."00"
	})
end

function GameScene:update()
	if self.paused and self.frame_steps == 0 then
		self.game.pause_time = self.game.pause_time + love.timer.getDelta() / (1/60)
	else
		if self.frame_steps > 0 then
			self.game.toolassisted = true
			self.frame_steps = self.frame_steps - 1
		end
		local inputs = {}
		for input, value in pairs(self.inputs) do
			inputs[input] = value
		end
		self.game:update(inputs, self.ruleset)
		self.game.grid:update()
		DiscordRPC:update({
			details = self.game.rpc_details,
			state = self.game.name,
			largeImageKey = "ingame-"..self.game:getBackground().."00"
		})
	end
end

function GameScene:render()
	self.game:draw(self.paused)
	if self.game.pause_time > 0 or self.game.pause_count > 0 then
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setFont(font_3x5_2)
		love.graphics.printf(string.format(
			"%d PAUSE%s (%s)",
			self.game.pause_count,
			self.game.pause_count == 1 and "" or "S",
			formatTime(self.game.pause_time)
		), 0, 0, 635, "right")
	end
	if TAS_mode or self.game.toolassisted then
		love.graphics.setFont(font_3x5_4)
		love.graphics.setColor(1, 1, 1, 0.2)
		love.graphics.printf(
			"T A S", -295, 100, 150, "center", 0, 8, 8
		)
	end
end

local movement_directions = {"left", "right", "down", "up"}
local opposite_directions = {left = "right", right = "left", up = "down", down = "up"}

function GameScene:onInputPress(e)
	if (
		self.game.game_over or self.game.completed
	) and (
		e.input == "menu_decide" or
		e.input == "menu_back" or
		e.input == "mode_exit" or
		e.input == "retry"
	) then
		local highscore_entry = self.game:getHighscoreData()
		local highscore_hash = self.game.hash .. "-" .. self.ruleset.hash
		submitHighscore(highscore_hash, highscore_entry)
		switchBGM(nil)
		self.game:onExit()
		sortReplays()
		scene = e.input == "retry" and GameScene(self.retry_mode, self.retry_ruleset, self.secret_inputs) or TitleScene.menu_screens[1]()
		scene.safety_frames = 2
	elseif e.input == "frame_step" and TAS_mode then
		self.frame_steps = self.frame_steps + 1
	elseif e.input == "retry" then
		switchBGM(nil)
		pitchBGM(1)
		self.game:onExit()
		scene = GameScene(self.retry_mode, self.retry_ruleset, self.secret_inputs)
	elseif e.input == "pause" and not (self.game.game_over or self.game.completed) then
		self.paused = not self.paused
		if self.paused then
			pauseBGM()
			table.insert(self.game.pause_timestamps, self.game.frames)
			self.game.pause_count = self.game.pause_count + 1
		else
			resumeBGM()
		end
	elseif e.input == "mode_exit" then
		switchBGM(nil)
		self.game:onExit()
		scene = TitleScene.menu_screens[1]()
	elseif e.input and string.sub(e.input, 1, 5) ~= "menu_" and e.input ~= "frame_step" then
		self.inputs[e.input] = true
		if config.gamesettings["diagonal_input"] == 3 and opposite_directions[e.input] then
			if self.inputs[self.movement_queue[1]] then
				self.inputs[self.movement_queue[1]] = false
			end
			table.insert(self.movement_queue, 1, e.input)
		end
		if config.gamesettings["diagonal_input"] == 4 then
			if self.inputs[opposite_directions[e.input]] then
				self.inputs[opposite_directions[e.input]] = false
			end
			if opposite_directions[e.input] then
				table.insert(self.movement_queue, 1, e.input)
			end
		end
	end
end

function GameScene:onInputRelease(e)
	if e.input and string.sub(e.input, 1, 5) ~= "menu_" then
		self.inputs[e.input] = false
		if config.gamesettings["diagonal_input"] == 3 and opposite_directions[e.input] then
			for key, value in ipairs(self.movement_queue) do
				if e.input == value then
					table.remove(self.movement_queue, key)
					local recent_input = self.movement_queue[1]
					if recent_input then
						self.inputs[recent_input] = true
					end
					break
				end
			end
		elseif config.gamesettings["diagonal_input"] == 4 and opposite_directions[e.input] then
			for key, value in ipairs(self.movement_queue) do
				if e.input == value then
					table.remove(self.movement_queue, key)
					for k2, v2 in ipairs(self.movement_queue) do
						if opposite_directions[v2] == e.input then
							self.inputs[opposite_directions[e.input]] = true
						end
					end
					break
				end
			end
		end
	end
end

function submitHighscore(hash, data)
	if not highscores[hash] then highscores[hash] = {} end
	table.insert(highscores[hash], data)
	saveHighscores()
end

return GameScene
