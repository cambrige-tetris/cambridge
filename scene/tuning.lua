local TuningScene = AbstractConfigScene:extend()

TuningScene.title = "Tuning Settings"
TuningScene.config_type = "tunings"

require 'load.save'
require 'libs.simple-slider'

local function curryTimingFormatFunction(format_condition, condition)
	return function (input)
		if input == condition then
			return format_condition
		end
		return string.format("%d ms (%d frame%s)", input * (1000 / getTargetFPS()), input, input > 1 and "s" or "")
	end
end

---@type settings_config_option[]
TuningScene.options = {
	-- Serves as a reference for the options available in the menu. Format: {name in config, name as displayed if applicable, slider name}
	{
		config_name = "das",
		display_name = "Delayed Auto Shift (DAS)",
		description = "Set it too fast, and you'd slip. Set it too slow, you'd feel sluggish.",
		format = curryTimingFormatFunction("No delay", 0),
		sound_effect_name = "cursor",
		min = 0,
		max = 20,
		type = "slider",
		default = 10,
		setter = function(v)
			config.das = math.floor(v)
			config.tunings.das = math.floor(v)
		end
	},
	{
		config_name = "arr",
		display_name = "Auto Repeat Rate (ARR)",
		description = "This changes how fast you move pieces, only if modes doesn't use its own ARR. Higher -> Slower, Lower -> Faster.",
		format = curryTimingFormatFunction("Instant", 0),
		sound_effect_name = "cursor",
		min = 0,
		max = 6,
		type = "slider",
		default = 2,
		setter = function(v)
			config.arr = math.floor(v)
			config.tunings.arr = math.floor(v)
		end
	},
	{
		config_name = "dcd",
		display_name = "DAS Cut Delay (DCD)",
		description = "When you rotate, softdrop, or hard drop a piece, the auto-shift delay is increased "..
		              "by specified amount of frames if the mode allows that configuration, or the amount the modes forces on.",
		format = curryTimingFormatFunction("Disabled (0 frames)", 0),
		sound_effect_name = "cursor",
		min = 0,
		max = 6,
		type = "slider",
		default = 0,
		setter = function(v)
			config.dcd = math.floor(v)
			config.tunings.dcd = math.floor(v)
		end
	},
	{
		config_name = "menu_das",
		display_name = "DAS in menus",
		description = "Delayed Auto Shift, in menus.\nSet it too fast, and you'd slip. Set it too slow, you'd feel sluggish.",
		format = curryTimingFormatFunction("No delay", 0),
		sound_effect_name = "cursor",
		min = 3,
		max = 20,
		type = "slider",
		default = 15,
	},
	{
		config_name = "menu_arr",
		display_name = "ARR in menus",
		description = "This changes how quickly you auto-repeat a directional press in menus. Higher -> Slower, Lower -> Faster.",
		format = curryTimingFormatFunction("SLIPPERY (16ms/1f)", 1),
		sound_effect_name = "cursor",
		min = 1,
		max = 8,
		type = "slider",
		default = 4,
	},
	{
		config_name = "mode_dynamic_arr",
		display_name = "Dyn. Select Mode ARR",
		description = "Dynamic Select Mode Auto Repeat Rate. The one menu that gradually decreases auto repeat delay if it's on.",
		sound_effect_name = "cursor",
		type = "options",
		options = {"On", "Off"},
		default = 1,
	},
}

function TuningScene:new()
	self.spacing = 30
	config.tunings.das = config.das
	config.tunings.arr = config.arr
	config.tunings.dcd = config.dcd
	self.super.new(self, 200)
	DiscordRPC:update({
		details = "In settings",
		state = "Changing tuning settings",
	})
end

function TuningScene:render()
	love.graphics.setColor(1, 1, 1, 1)
	drawBackground("options_game")

	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.setFont(font_8x11)
	love.graphics.print("TUNING SETTINGS", 80, 43)

	love.graphics.setFont(font_3x5_2)
	love.graphics.print("These settings will only apply to modes that do not use their\nown tunings. Menu tunings are separate from gameplay tunings.", 80, 80)

	self:renderSettings()
end

function TuningScene:onConfirm()
	config.menu_das = config.tunings.menu_das
	config.menu_arr = config.tunings.menu_arr
end

return TuningScene