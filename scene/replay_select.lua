local ReplaySelectScene = Scene:extend()

ReplaySelectScene.title = "Replays"

local replays_loaded = 0
local sha2 = require "libs.sha2"
local binser = require 'libs.binser'

local current_submenu = 0
local current_replay = 1

local loading_replays

function ReplaySelectScene:new()
	-- fully reload custom modules
	unloadModules()
	initModules()

	self.safety_frames = 0
	self.frames_since_error = 0

	self.replay_count = #(love.filesystem.getDirectoryItems("replays"))
	if not loaded_replays and not loading_replays then
		loading_replays = true
		replays_loaded = 0
		loadReplayList()
		self.state_string = ""
		DiscordRPC:update({
			details = "In menus",
			state = "Loading replays...",
			largeImageKey = "ingame-000"
		})
		return
	end
	self.display_error = false
	if #replays == 0 then
		self.display_warning = true
		current_replay = 1
	else
		self.display_warning = false
	end

	self.menu_state = {
		submenu = current_submenu,
		replay = current_replay,
	}
	self.das = 0
	self.height_offset = 0
	self.auto_menu_offset = 0
	DiscordRPC:update({
		details = "In menus",
		state = "Choosing a replay",
		largeImageKey = "ingame-000"
	})
end

function insertReplay(replay)
	for key, value in pairs(replay) do
		replay[key] = toFormattedValue(value)
	end
	if replay.highscore_data then
		for key, value in pairs(replay.highscore_data) do
			replay.highscore_data[key] = toFormattedValue(value)
		end
	end
	local mode_name = replay.mode
	replays[#replays+1] = replay
	if dict_ref[mode_name] ~= nil and mode_name ~= "znil" then
		table.insert(replay_tree[dict_ref[mode_name] ], #replays)
	end
	local branch_index = 0
	for index, value in ipairs(replay_tree) do
		if value.name == "All" then
			branch_index = index
			break
		end
	end
	table.insert(replay_tree[branch_index], #replays)
end
function sortReplays()
	if not replay_tree then return end
	local function padnum(d) return ("%03d%s"):format(#d, d) end
	table.sort(replay_tree, function(a,b)
	return tostring(a.name):gsub("%d+",padnum) < tostring(b.name):gsub("%d+",padnum) end)
	for key, submenu in pairs(replay_tree) do
		table.sort(submenu, function(a, b)
			return replays[a]["timestamp"] > replays[b]["timestamp"]
		end)
	end
end

function ReplaySelectScene:update()
	self.safety_frames = self.safety_frames - 1
	self.frames_since_error = self.frames_since_error + 1
	if not loaded_replays then
		self.state_string = love.thread.getChannel('load_state'):peek()
		local replay = love.thread.getChannel('replay'):pop()
		local load = love.thread.getChannel( 'loaded_replays' ):pop()
		while replay do
			replays_loaded = replays_loaded + 1
			local mode_name = replay.mode
			replays[#replays+1] = replay
			if dict_ref[mode_name] ~= nil and mode_name ~= "znil" then
				table.insert(replay_tree[dict_ref[mode_name] ], #replays)
			end
			table.insert(replay_tree[1], #replays)
			replay = love.thread.getChannel('replay'):pop()
		end
		if load then
			loaded_replays = true
			loading_replays = false
			local function padnum(d) return ("%03d%s"):format(#d, d) end
			table.sort(replay_tree, function(a,b)
			return tostring(a.name):gsub("%d+",padnum) < tostring(b.name):gsub("%d+",padnum) end)
			for key, submenu in pairs(replay_tree) do
				table.sort(submenu, function(a, b)
					return replays[a]["timestamp"] > replays[b]["timestamp"]
				end)
			end
			scene = ReplaySelectScene()
		end
		return -- It's there to avoid input response when loading.
	end
	if self.das_up or self.das_down or self.das_left or self.das_right then
		self.das = self.das + 1
	else
		self.das = 0
	end
	if self.menu_state.submenu > 0 then
		if #replay_tree[self.menu_state.submenu] == 0 then
			return
		end
	end
	if self.auto_menu_offset ~= 0 then
		self:changeOption(self.auto_menu_offset < 0 and -1 or 1)
		if self.auto_menu_offset > 0 then self.auto_menu_offset = self.auto_menu_offset - 1 end
		if self.auto_menu_offset < 0 then self.auto_menu_offset = self.auto_menu_offset + 1 end
	end
	if self.das >= 15 then
		local change = 0
		if self.das_up then
			change = -1
		elseif self.das_down then
			change = 1
		elseif self.das_left then
			change = -9
		elseif self.das_right then
			change = 9
		end
		self:changeOption(change)
		self.das = self.das - 4
	end

	DiscordRPC:update({
		details = "In menus",
		state = "Choosing a replay",
		largeImageKey = "ingame-000"
	})
end

function ReplaySelectScene:render()
	drawBackground(0)

	-- Same graphic as mode select
	--love.graphics.draw(misc_graphics["select_mode"], 20, 40)

	love.graphics.setFont(font_8x11)
	if loaded_replays then
		local b = cursorHighlight(0, 32, 40, 30)
		love.graphics.setColor(1, 1, b, 1)
		love.graphics.printf("<-", font_3x5_4, 0, 32, 40, "center")
		love.graphics.setColor(1, 1, 1, 1)
	end
	if not loaded_replays then
		love.graphics.setFont(font_3x5_3)
		love.graphics.printf(
			"Loading replays... Please wait",
			80, 200, 480, "center"
		)
		love.graphics.printf(
			"Thread's current job:\n"..(self.state_string or "nil"),
			0, 250, 640, "center"
		)
		love.graphics.printf(
			("Loaded %d/%d replays"):format(replays_loaded, self.replay_count),
			0, 350, 640, "center"
		)
		return
	elseif self.menu_state.submenu > 0 then
		love.graphics.print("SELECT REPLAY", 40, 35)
		love.graphics.setFont(font_3x5_3)
		love.graphics.printf("MODE: "..replay_tree[self.menu_state.submenu].name, 300, 35, 320, "right")
	else
		love.graphics.print("SELECT MODE TO REPLAY", 40, 35)
	end

	if self.display_warning then
		love.graphics.setFont(font_3x5_3)
		love.graphics.printf(
			"You have no replays.",
			80, 200, 480, "center"
		)
		love.graphics.setFont(font_3x5_2)
		love.graphics.printf(
			"Come back to this menu after playing some games. " ..
			"Press any button to return to the main menu.",
			80, 250, 480, "center"
		)
		return
	elseif self.display_error then
		love.graphics.setFont(font_3x5_3)
		love.graphics.printf(
			"You are missing this mode or ruleset.",
			80, 200, 480, "center"
		)
		love.graphics.setFont(font_3x5_2)
		love.graphics.printf(
			"Come back after getting the proper mode or ruleset. " ..
			"Press any button to return to the main menu.",
			80, 250, 480, "center"
		)
		return
	end

	self.height_offset = interpolateNumber(self.height_offset / 20, self.menu_state.replay) * 20
	if not self.chosen_replay then
		love.graphics.setColor(1, 1, 1, 0.5)
		love.graphics.rectangle("fill", 3, 258 + (self.menu_state.replay * 20) - self.height_offset, 634, 22)
	end
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(font_3x5_2)
	if self.menu_state.submenu == 0 then
		for idx, branch in ipairs(replay_tree) do
			if(idx >= self.height_offset/20-10 and idx <= self.height_offset/20+10) then
				local b = cursorHighlight(0, (260 - self.height_offset) + 20 * idx, 640, 20)
				love.graphics.setColor(1,1,b,fadeoutAtEdges((-self.height_offset) + 20 * idx, 180, 20))
				love.graphics.printf(branch.name, 6, (260 - self.height_offset) + 20 * idx, 640, "left")
			end
		end
	elseif self.chosen_replay then
		love.graphics.setFont(font_3x5_2)
		love.graphics.setColor(1, 1, 0)
		love.graphics.printf("Scrolling a list of replays is disabled.", 0, 10, 640, "center")
		love.graphics.setColor(1, 1, 1)
		local pointer = replay_tree[self.menu_state.submenu][self.menu_state.replay]
		local replay = replays[pointer]
		if replay then
			local idx = 0
			if replay.ineligible then
				love.graphics.setFont(font_3x5_2)
				love.graphics.setColor(1, 1, 0, 1)
				love.graphics.printf("This replay is ineligible for leaderboards", 0, 80, 640, "center")
				love.graphics.setColor(1, 1, 1, 1)
				idx = idx + 1
			end
			if replay.toolassisted then
				love.graphics.setFont(font_3x5_2)
				love.graphics.setColor(1, 1, 0, 1)
				love.graphics.printf("This replay has likely used in-game TAS", 0, 80, 640, "center")
				love.graphics.setColor(1, 1, 1, 1)
				idx = idx + 1
			end
			if replay_tree[self.menu_state.submenu].name == "All" then
				love.graphics.setFont(font_3x5_4)
				love.graphics.printf("Mode: " .. replay["mode"], 0, 80 + idx * 20, 640, "center")
				idx = idx + 2
			end
			love.graphics.setFont(font_3x5_3)
			love.graphics.printf(os.date("Timestamp: %c", replay["timestamp"]), 0, 80 + idx * 20, 640, "center")
			if replay.cambridge_version then
				idx = idx + 1.5
				local version_text_color = {1, 1, 1, 1}
				if replay.cambridge_version ~= version then
					version_text_color = {1, 0, 0, 1}
				end
				love.graphics.setFont(font_3x5_2)
				love.graphics.printf({"Cambridge version for this replay: ", version_text_color, replay.cambridge_version}, 0, 80 + idx * 20, 640, "center")
			end
			if replay.ruleset_override then
				idx = idx + 1
				love.graphics.setFont(font_3x5_2)
				love.graphics.setColor(1, 1, 0, 1)
				love.graphics.printf("This mode overrides the ruleset.", 0, 80 + idx * 20, 640, "center")
				love.graphics.setColor(1, 1, 1, 1)
			end
			if replay.pause_count and replay.pause_time then
				idx = idx + 1
				love.graphics.setFont(font_3x5_2)
				love.graphics.printf(("Pause count: %d, Time Paused: %s"):format(replay.pause_count, formatTime(replay.pause_time)), 0, 80 + idx * 20, 640, "center")
			end
			if replay.sha256_table then
				if config.visualsettings.debug_level > 2 then
					idx = idx + 1
					love.graphics.setFont(font_3x5)
					love.graphics.printf(("SHA256 replay hashes:\n   Mode: %s\nRuleset: %s"):format(replay.sha256_table.mode, replay.sha256_table.ruleset), 0, 80 + idx * 20, 640, "center")
					idx = idx + 1.5
					love.graphics.printf(("SHA256 comparison hashes:\n   Mode: %s\nRuleset: %s"):format(self.replay_sha_table.mode, self.replay_sha_table.ruleset), 0, 80 + idx * 20, 640, "center")
					idx = idx + 0.5
				end
			end
			if next(self.highscores_indexing) == nil then
				love.graphics.setFont(font_3x5_3)
				love.graphics.printf("Level: ".. replay["level"], 0, 100 + idx * 20, 640, "center")
			else
				love.graphics.setFont(font_3x5_2)
				if self.error_msg then
					love.graphics.setColor(0.5, 0.5, 0.5)
				end
				love.graphics.printf("In-replay highscore data:", 0, 100 + idx * 20, 640, "center")
				for key, value in pairs(self.highscores_indexing) do
					local text_content = key..": "..tostring(replay.highscore_data[key])
					if self.highscores_data_comparison and replay.highscore_data[key] ~= self.highscores_data_comparison[key] then
						text_content = {key..": ", self.highscores_data_comparison[key] or "nil",
						{1, 0, 0, 1}, " -", tostring(replay.highscore_data[key]), "- "}
					end
					love.graphics.printf(text_content, 0, 110 + (idx + self.highscores_idx_offset[value]) * 20, 640, "center")
				end
				idx = idx + self.highscores_idx_offset[#self.highscores_idx_offset]
			end
			if self.error_msg then
				idx = idx + 0.8
				local whiteness = -0.3 + self.frames_since_error / 30
				love.graphics.setColor(1, whiteness, whiteness)
				love.graphics.setFont(font_3x5_2)
				love.graphics.printf("Replay has crashed! Error message:\n" .. self.error_msg, 0, 120 + idx * 20, 640, "center")
				idx = idx + self.error_lines
				
				love.graphics.setColor(1, 1, 1)
				love.graphics.printf("RMB or " .. (config.input.keys.menu_back or "???")..": Return", 0, 140 + idx * 20, 640, "center")
			else
				love.graphics.setColor(1, 1, 1)
				love.graphics.setFont(font_3x5_2)
				love.graphics.printf("LMB or ".. (config.input.keys.menu_decide or "???") ..": Start\nRMB or " ..
				(config.input.keys.menu_back or "???")..": Return\n Generic 1: Verify highscore data", 0, 140 + idx * 20, 640, "center")
			end
		end
	else
		if #replay_tree[self.menu_state.submenu] == 0 then
			love.graphics.setFont(font_3x5_2)
			love.graphics.printf(
				"This submenu doesn't contain replays of this mode. ",
				80, 250, 480, "center"
			)
			return
		end
		love.graphics.setColor(1,1,1,fadeoutAtEdges(-self.height_offset - 80, 180, 20))
		love.graphics.printf("Color legend:", 0, 180 - self.height_offset, 640, "center")
		love.graphics.printf({
		 {1, 1, 1, 1}, "White: Contains highscore data and isn't ineligible\n",
		 {1, 0, 0, 1}, "Red", {1, 1, 1, 1}, ": A replay that either has used TAS or is ineligible\n",
		 {1, 0.5, 0.8, 1}, "Pink", {1, 1, 1, 1}, ": A replay that doesn't contain highscore data or is legacy"}, 0, 200 - self.height_offset, 640, "center")
		for idx, replay_idx in ipairs(replay_tree[self.menu_state.submenu]) do
			if(idx >= self.height_offset/20-10 and idx <= self.height_offset/20+10) then
				local replay = replays[replay_idx]
				local display_string
				if replay_tree[self.menu_state.submenu].name == "All" then
					display_string = os.date("%c", replay["timestamp"]).." - ".. replay["mode"]
				else
					display_string = os.date("%c", replay["timestamp"])
				end
				if not replay.ruleset_override then
					display_string = display_string.." - "..replay["ruleset"]
				end
				if replay["level"] ~= nil then
					display_string = display_string.." - Level: "..replay["level"]
				end
				if replay["timer"] ~= nil then
					display_string = display_string.." - Time: "..formatTime(replay["timer"])
				end
				if #display_string > 78 and idx ~= self.menu_state.replay then
					display_string = display_string:sub(1, 75) .. "..."
				end
				local b, g = cursorHighlight(0, (260 - self.height_offset) + 20 * idx, 640, 20), 1
				if not replay["highscore_data"] or next(replay["highscore_data"]) == nil then
					g = 0.5
					b = 0.8
				end
				if replay["toolassisted"] or replay["ineligible"] then
					g = 0
					b = 0
				end
				love.graphics.setColor(1,g,b,fadeoutAtEdges((-self.height_offset) + 20 * idx, 180, 20))
				drawWrappingText(display_string, 6, (260 - self.height_offset) + 20 * idx, 628, "left")
			end
		end
	end
end

function ReplaySelectScene.indexModeFromReplay(replay)
	for key, value in pairs(recursionStringValueExtract(game_modes, "is_directory")) do
		if value.name == replay["mode"] or value.hash == replay["mode_hash"] then
			return value
		end
	end
end

function ReplaySelectScene.indexRulesetFromReplay(replay)
	for key, value in pairs(recursionStringValueExtract(rulesets, "is_directory")) do
		if value.name == replay["ruleset"] or value.hash == replay["ruleset_hash"] then
			return value
		end
	end
end

---@param highscore_data table
---@param font love.Font
---@return table
function ReplaySelectScene:generateHighscoreRowOffsets(highscore_data, font)
	local highscores_idx_offset = {}
	for key, value in pairs(self.highscores_indexing) do
		local idx = 0
		local _, wrappedtext = font:getWrap(value..": "..tostring(highscore_data[value]), 640)
		if self.highscores_data_comparison then
			_, wrappedtext = font:getWrap(key..": "..tostring(self.highscores_data_comparison[key]).." -"..tostring(highscore_data[key]).."- ", 640)
		end
		for _ in pairs(wrappedtext) do
			idx = idx + 0.8
		end
		highscores_idx_offset[value] = idx
	end
	for i = 2, #highscores_idx_offset do
		highscores_idx_offset[i] = highscores_idx_offset[i] + highscores_idx_offset[i-1]
	end
	return highscores_idx_offset
end

function ReplaySelectScene:startReplay()
	if self.menu_state.submenu == 0 then
		self.menu_state.submenu = self.menu_state.replay
		self.menu_state.replay = 1
		self.height_offset = 0
		playSE("main_decide")
		return
	elseif self.menu_state.submenu > 0 then
		if #replay_tree[self.menu_state.submenu] == 0 then
			self.menu_state.submenu = 0
			self.menu_state.replay = 1
			return
		end
	end
	current_submenu = self.menu_state.submenu
	current_replay = self.menu_state.replay
	-- Get game mode and ruleset
	local pointer = replay_tree[self.menu_state.submenu][self.menu_state.replay]
	local replay = replays[pointer]
	local mode = self.indexModeFromReplay(replay)
	local rules = self.indexRulesetFromReplay(replay)
	if mode == nil or (rules == nil and not replay.ruleset_override) then
		self.display_error = true
		return
	end

	if replay["highscore_data"] and not self.chosen_replay then
		self.chosen_replay = true
		self.highscores_data_comparison = nil
		self.highscores_data_matching = nil
		self.error_msg = nil
		self.auto_menu_offset = 0
		self.replay_sha_table = {mode = sha2.sha256(binser.serialize(mode)), ruleset = sha2.sha256(binser.serialize(rules))}
		playSE("main_decide")
		self.das_down = nil
		self.das_up = nil
		self.das_left = nil
		self.das_right = nil
		self.highscores_indexing = HighscoresScene.getHighscoreIndexing({replay["highscore_data"]})
		self.highscores_idx_offset = self:generateHighscoreRowOffsets(replay["highscore_data"], font_3x5_2)
		return
	end

	if self:enterReplay(replay, mode, rules) then
		-- Same as mode decide
		playSE("mode_decide")
	end
	
end

function ReplaySelectScene:enterReplay(replay, mode, ruleset)
	if self.error_msg then
		return false
	end
	local prev_scene = scene
	local success
	
	-- TODO compare replay versions to current versions for Cambridge, ruleset, and mode
	success, scene = pcall(ReplayScene, 
		deepcopy(replay), --This has to be done to avoid serious glitches with it.
		mode,
		ruleset
	)
	if not success then
		self.frames_since_error = 0
		self.error_msg = scene
		local _, wrappedtext = font_3x5_2:getWrap(self.error_msg, 640)
		self.error_lines = #wrappedtext
		scene = prev_scene
		playSE("error")
	end
	return success
end

function ReplaySelectScene:verifyHighscoreData()
	current_submenu = self.menu_state.submenu
	current_replay = self.menu_state.replay
	-- Get game mode and ruleset
	local pointer = replay_tree[self.menu_state.submenu][self.menu_state.replay]
	local replay = replays[pointer]
	local mode = self.indexModeFromReplay(replay)
	local rules = self.indexRulesetFromReplay(replay)

	local prev_scene = scene
	
	if not self:enterReplay(replay, mode, rules) then
		return
	end

	love.graphics.setColor(0, 0, 0, 0.5)
	love.graphics.rectangle("fill", -9999, -9999, 19998, 19998)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.printf("Please wait...\nVerifying highscore data...", font_3x5_4, 0, 160, 640, "center")
	love.graphics.present()
	local game_scene = scene
	self.safety_frames = 2
	local prev_sfx_volume = config.sfx_volume
	local inactivity_frames = 0
	while inactivity_frames < 300 do
		config.sfx_volume = 0
		game_scene:update()
		game_scene.game.save_replay = false
		if game_scene.game.game_over or game_scene.game.completed then
			inactivity_frames = inactivity_frames + 1
		end
	end
	config.sfx_volume = prev_sfx_volume
	saveConfig()
	game_scene.game:onExit()
	switchBGM(nil)
	local highscore_data = game_scene.game:getHighscoreData()
	scene = prev_scene
	if not equals(replay["highscore_data"], highscore_data) then
		self.highscores_data_comparison = highscore_data
		self.highscores_indexing = HighscoresScene.getHighscoreIndexing({replay["highscore_data"], highscore_data})
		self.highscores_idx_offset = self:generateHighscoreRowOffsets(replay["highscore_data"], font_3x5_2)
		playSE("error")
	else
		self.highscores_data_matching = true
	end
end

function ReplaySelectScene:onInputPress(e)
	if self.safety_frames > 0 then return end
	if (self.display_warning or self.display_error) and e.input then
		scene = TitleScene()
	elseif e.type == "mouse" and loaded_replays then
		if e.button == 1 then
			if e.y < 62 and e.x > 0 and e.y > 32 and e.x < 50 then
				playSE("menu_cancel")
				if self.chosen_replay then
					self.chosen_replay = false
					return
				end
				current_submenu = 0
				current_replay = self.menu_state.replay
				if self.menu_state.submenu ~= 0 then
					self.menu_state.submenu = 0
					self.menu_state.replay = 1
					return
				end
				scene = TitleScene()
				return
			end
			if self.display_error or self.display_warning then
				scene = TitleScene()
				return
			end
			self.auto_menu_offset = math.floor((e.y - 260)/20)
			if self.auto_menu_offset == 0 or self.chosen_replay then
				self:startReplay()
				self.auto_menu_offset = 0
			end
		end
		if e.button == 2 and self.chosen_replay then
			playSE("menu_cancel")
			self.chosen_replay = false
		end
	elseif not loaded_replays then
		if e.input == "menu_back" then
			playSE("menu_cancel")
			scene = TitleScene()
		end
	elseif e.type == "wheel" and not self.chosen_replay then
		if e.y ~= 0 then
			self:changeOption(-e.y)
		end
	elseif e.input == "generic_1" and self.chosen_replay then
		self:verifyHighscoreData()
	elseif e.input == "menu_decide" then
		self:startReplay()
	elseif self.chosen_replay then
		if e.input == "menu_back" then
			self.chosen_replay = false
		end
	elseif e.input == "menu_up" then
		self:changeOption(-1)
		self.das_up = true
		self.das_down = nil
		self.das_left = nil
		self.das_right = nil
	elseif e.input == "menu_down" then
		self:changeOption(1)
		self.das_down = true
		self.das_up = nil
		self.das_left = nil
		self.das_right = nil
	elseif e.input == "menu_left" then
		self:changeOption(-9)
		self.das_left = true
		self.das_right = nil
		self.das_up = nil
		self.das_down = nil
	elseif e.input == "menu_right" then
		self:changeOption(9)
		self.das_right = true
		self.das_left = nil
		self.das_up = nil
		self.das_down = nil
	elseif e.input == "menu_back" then
		playSE("menu_cancel")
		if self.menu_state.submenu ~= 0 then
			self.menu_state.submenu = 0
			self.menu_state.replay = 1
			return
		end
		current_submenu = 0
		current_replay = self.menu_state.replay
		scene = TitleScene()
	end
end

function ReplaySelectScene:onInputRelease(e)
	if e.input == "menu_up" then
		self.das_up = nil
	elseif e.input == "menu_down" then
		self.das_down = nil
	elseif e.input == "menu_right" then
		self.das_right = nil
	elseif e.input == "menu_left" then
		self.das_left = nil
	end
end

function ReplaySelectScene:changeOption(rel)
	local len
	if self.menu_state.submenu > 0 then
		if #replay_tree[self.menu_state.submenu] == 0 then
			return
		end
	end
	if self.menu_state.submenu == 0 then
		len = #replay_tree
	else
		len = #replay_tree[self.menu_state.submenu]
	end
	self.menu_state.replay = Mod1(self.menu_state.replay + rel, len)
	playSE("cursor")
end

return ReplaySelectScene
