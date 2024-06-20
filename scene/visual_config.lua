local ConfigScene = Scene:extend()

ConfigScene.title = "Visual Settings"

require 'load.save'

ConfigScene.options = {
	-- this serves as reference to what the options' values mean i guess?
	-- Format: {name in config, displayed name, options, description}
	{
		config_name = "display_gamemode",
		display_name = "Display Info",
		options = {"On", "Off"},
		description = "Shows some game info.\nWhile playing (depends on gamemode): <mode_name> - <ruleset_name>\nIf enabled or on title screen: (<target_fps>) <fps> fps - <version>"
	},
	{
		config_name = "smooth_movement",
		display_name = "Smooth Piece Drop",
		options = {"On", "Off"},
	},
	{
		config_name = "smooth_scroll",
		display_name = "Smooth Scrolling",
		options = {"On", "Off"},
		description = "Option to let menus and numbers smoothly interpolate\nif enabled. This affects interpolateNumber function."
	},
	{
		config_name = "cursor_highlight",
		display_name = "Cursor Highlight",
		options = {"On", "Off"},
	},
	{
		config_name = "cursor_type",
		display_name = "Cursor Type",
		options = {"Standard", "Tetro48's"},
		description = "Standard is a cursor of an operating system\nTetro48's cursor is custom-made"
	},
	{
		config_name = "mode_entry",
		display_name = "Mode Entry",
		options = {"Instant", "Animated"},
	},
	{
		config_name = "tagline_position",
		display_name = "Tagline placement",
		options = {"Top", "Bottom", "None"},
	},
	{
		config_name = "mode_select_type",
		display_name = "Mode Select Type",
		options = {"Default", "Oshi's idea"},
	},
	{
		config_name = "credits_position",
		display_name = "Credits Pos-ing",
		options = {"Right", "Center"},
	},
	{
		config_name = "debug_level",
		display_name = "Debug Level",
		options = {"Off", "Min", "Max"},
		description = "How much debug info do you want displayed?\nMin: Lua memory usage data\nMax: Memory usage, GPU stats data and 2 true hashes stored in replays"
	},
	{
		config_name = "stretch_background",
		display_name = "Stretch Background",
		options = {"Off", "On"},
		description = "Whether to fit the background image to 4:3 aspect ratio, or the aspect ratio of the game window"
	}
}
local optioncount = #ConfigScene.options

function ConfigScene:new()
	-- load current config
	self.config = config.input
	self.highlight = 1

	DiscordRPC:update({
		details = "In settings",
		state = "Changing visual settings",
	})
end

function ConfigScene:render()
	love.graphics.setColor(1, 1, 1, 1)
	drawBackground("options_game")

	love.graphics.setFont(font_8x11)
	love.graphics.print("VISUAL SETTINGS", 80, 43)
	local b = cursorHighlight(20, 40, 50, 30)
	love.graphics.setColor(1, 1, b, 1)
	love.graphics.printf("<-", font_3x5_4, 20, 40, 50, "center")
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(font_3x5_2)
	love.graphics.print("(THIS WILL NOT BE STORED IN REPLAYS)", 80, 80)

	love.graphics.setColor(1, 1, 1, 0.5)
	love.graphics.rectangle("fill", 25, 98 + self.highlight * 20, 170, 22)

	love.graphics.setFont(font_3x5_2)
	for i, option in ipairs(ConfigScene.options) do
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.printf(option.display_name, 40, 100 + i * 20, 150, "left")
		for j, setting in ipairs(option.options) do
			local b = cursorHighlight(100 + 110 * j, 100 + i * 20,100,20)
			love.graphics.setColor(1, 1, b, config.visualsettings[option.config_name] == j and 1 or 0.5)
			love.graphics.printf(setting, 100 + 110 * j, 100 + i * 20, 100, "center")
		end
	end
	love.graphics.setColor(1, 1, 1, 1)
	if self.options[self.highlight].description then
		love.graphics.printf("Description: " .. self.options[self.highlight].description, 20, 380, 600, "left")
	end

	love.graphics.setColor(1, 1, 1, 0.75)
end

function ConfigScene:update()
	if self.das_up or self.das_down or self.das_left or self.das_right then
		self.das = self.das + 1
	else
		self.das = 0
	end
	if self.das >= 15 then
		local change = 0
		if self.das_up then
			change = -1
		elseif self.das_down then
			change = 1
		end
		self:changeHighlight(change)
		self.das = self.das - 4
	end
end

function ConfigScene:changeHighlight(rel)
	playSE("cursor")
	self.highlight = Mod1(self.highlight+rel, optioncount)
end

function ConfigScene:onInputPress(e)
	if e.type == "mouse" then
		if e.x > 20 and e.y > 40 and e.x < 70 and e.y < 70 then
			playSE("mode_decide")
			saveConfig()
			scene = SettingsScene()
		end
		for i, option in ipairs(ConfigScene.options) do
			for j, setting in ipairs(option.options) do
				if e.x > 100 + 110 * j and e.x < 200 + 110 * j then
					if e.y > 100 + i * 20 and e.y < 120 + i * 20 then
						self.main_menu_state = math.floor((e.y - 280) / 20)
						playSE("cursor_lr")
						config.visualsettings[option.config_name] = Mod1(j, #option.options)
					end
				end
				-- local option = ConfigScene.options[self.highlight]
			end
		end
	end
	if e.input == "menu_decide" then
		playSE("mode_decide")
		saveConfig()
		scene = SettingsScene()
	elseif e.input == "menu_up" then
		self:changeHighlight(-1)
		self.das_up = true
	elseif e.input == "menu_down" then
		self:changeHighlight(1)
		self.das_down = true
	elseif e.input == "menu_left" then
		playSE("cursor_lr")
		local option = ConfigScene.options[self.highlight]
		config.visualsettings[option.config_name] = Mod1(config.visualsettings[option.config_name]-1, #option.options)
	elseif e.input == "menu_right" then
		playSE("cursor_lr")
		local option = ConfigScene.options[self.highlight]
		config.visualsettings[option.config_name] = Mod1(config.visualsettings[option.config_name]+1, #option.options)
	elseif e.input == "menu_back" then
		playSE("menu_cancel")
		loadSave()
		scene = SettingsScene()
	end
end

function ConfigScene:onInputRelease(e)
	if e.input == "menu_up" then
		self.das_up = false
	elseif e.input == "menu_down" then
		self.das_down = false
	end
end

return ConfigScene
