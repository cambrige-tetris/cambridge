local ConfigScene = AbstractConfigScene:extend()

ConfigScene.title = "Game Settings"
ConfigScene.config_type = "gamesettings"

---@type settings_config_option[]
ConfigScene.options = {
	-- this serves as reference to what the options' values mean i guess?
	-- Format: {name in config, displayed name, uses slider?, options OR slider name}
	{
		config_name = "manlock",
		display_name = "Manual Locking",
		options = {"Per ruleset", "Per gamemode", "Harddrop", "Softdrop"},
		type = "options",
		default = 1,
	},
	{
		config_name = "piece_colour",
		display_name = "Piece Colours",
		options = {"Per ruleset", "Arika", "TTC"},
		type = "options",
		default = 1,
	},
	{
		config_name = "world_reverse",
		display_name = "A Button Rotation",
		options = {"Left", "Auto", "Right"},
		type = "options",
		default = 1,
	},
	{
		config_name = "spawn_positions",
		display_name = "Spawn Positions",
		options = {"Per ruleset", "In field", "Out of field"},
		type = "options",
		default = 1,
	},
	{
		config_name = "save_replay",
		display_name = "Save Replays",
		options = {"On", "Off"},
		type = "options",
		default = 1,
	},
	{
		config_name = "diagonal_input",
		display_name = "Movement Type",
		options = {"Standard", "4-way Abs.", "4-way LICP", "8-way LICP"},
		description = [[
SOCD cardinal resolutions. Standard: None.
4-way: No diagonals. 8-way: Yes diagonals, no opposing directions.
LICP: Last Input Controlled Priority. First button is inactive unless opposing/last input is released.]],
		type = "options",
		default = 1,
	},
	{
		config_name = "das_last_key",
		display_name = "DAS Last Key",
		options = {"Off", "On"},
		type = "options",
		default = 1,
	},
	{
		config_name = "buffer_lock",
		display_name = "Buffer Drop Type",
		options = {"Off", "Hold", "Tap"},
		type = "options",
		default = 1,
	},
	{
		config_name = "synchroes_allowed",
		display_name = "Synchroes",
		options = {"Per ruleset", "On", "Off"},
		description = "On: Pieces rotate first, then moves.\nOff: Piece moves first, then rotates.",
		type = "options",
		default = 1,
	},
	{
		config_name = "replay_name",
		display_name = "Replay file name",
		options = {"Full", "Date"},
		description = "Full: <mode_name> - <ruleset_name> - <date_time>.crp\nDate: <date_time>.crp",
		type = "options",
		default = 1,
	},
}
local optioncount = #ConfigScene.options

function ConfigScene:new()
	ConfigScene.super.new(self)

	DiscordRPC:update({
		details = "In settings",
		state = "Changing game settings",
	})
end

function ConfigScene:changeHighlight(rel)
	playSE("cursor")
	self.highlight = Mod1(self.highlight+rel, optioncount)
end

function ConfigScene:render()
	love.graphics.setColor(1, 1, 1, 1)
	drawBackground("options_game")

	love.graphics.setFont(font_8x11)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print("GAME SETTINGS", 80, 43)

	self:renderSettings()
end

return ConfigScene
