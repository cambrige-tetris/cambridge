local ConfigScene = AbstractConfigScene:extend()

ConfigScene.title = "Visual Settings"
ConfigScene.config_type = "visualsettings"

---@type settings_config_option[]
ConfigScene.options = {
	-- this serves as reference to what the options' values mean i guess?
	-- Format: {name in config, displayed name, options, description}
	{
		config_name = "display_gamemode",
		display_name = "Display Info",
		options = {"On", "Off"},
		description = "Shows some game info.\nWhile playing (depends on gamemode): <mode_name> - <ruleset_name>\nIf enabled or on title screen: (<target_fps>) <fps> fps - <version>",
		type = "options",
		default = 1,
	},
	{
		config_name = "smooth_movement",
		display_name = "Smooth Piece Drop",
		options = {"On", "Off"},
		type = "options",
		default = 1,
	},
	{
		config_name = "smooth_scroll",
		display_name = "Smooth Scrolling",
		options = {"On", "Off"},
		description = "Option to let menus and numbers smoothly interpolate\nif enabled. This affects interpolateNumber function.",
		type = "options",
		default = 1,
	},
	{
		config_name = "cursor_highlight",
		display_name = "Cursor Highlight",
		options = {"On", "Off"},
		type = "options",
		default = 1,
	},
	{
		config_name = "cursor_type",
		display_name = "Cursor Type",
		options = {"Standard", "Tetro48's"},
		description = "Standard is a cursor of an operating system\nTetro48's cursor is custom-made",
		type = "options",
		default = 1,
	},
	{
		config_name = "mode_entry",
		display_name = "Mode Entry",
		options = {"Instant", "Animated"},
		type = "options",
		default = 1,
	},
	{
		config_name = "tagline_position",
		display_name = "Tagline placement",
		options = {"Top", "Bottom", "None"},
		type = "options",
		default = 1,
	},
	{
		config_name = "mode_select_type",
		display_name = "Mode Select Type",
		options = {"Default", "Oshi's idea"},
		type = "options",
		default = 1,
	},
	{
		config_name = "credits_position",
		display_name = "Credits Pos-ing",
		options = {"Right", "Center"},
		type = "options",
		default = 1,
	},
	{
		config_name = "debug_level",
		display_name = "Debug Level",
		options = {"Off", "Min", "Max"},
		description = "How much debug info do you want displayed?\nMin: Lua memory usage data\nMax: Memory usage, GPU stats data and 2 true hashes stored in replays",
		type = "options",
		default = 1,
	},
	{
		config_name = "stretch_background",
		display_name = "Stretch Background",
		options = {"Off", "On"},
		description = "Whether to fit the background image to 4:3 aspect ratio, or the aspect ratio of the game window",
		type = "options",
		default = 1,
	}
}

function ConfigScene:new()
	ConfigScene.super.new(self)

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
	love.graphics.setFont(font_3x5_2)
	love.graphics.print("(THIS WILL NOT BE STORED IN REPLAYS)", 80, 80)

	self:renderSettings()
end

return ConfigScene
