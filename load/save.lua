local binser = require 'libs.binser'

function loadSave()
	config = loadFromFile('config.sav', true)
	highscores = loadFromFile('highscores.sav', true)
end

local configurable_inputs = {
	"menu_decide",
	"menu_back",
	"menu_left",
	"menu_right",
	"menu_up",
	"menu_down",
	"rotate_left",
	"rotate_left2",
	"rotate_right",
	"rotate_right2",
	"rotate_180",
	"hold",
	"retry",
	"mode_exit",
	"frame_step",
	"generic_1",
	"generic_2",
	"generic_3",
	"generic_4",
}

local function inputUpdaterConditions(input_table)
	if type(input_table) ~= "table" then return false end
	for key, value in pairs(input_table) do
		if table.contains(configurable_inputs, key) then
			return false
		end
	end
	return true
end

local function migrateInputConfig()
	if inputUpdaterConditions(config.input.keys) then
		local new_key_inputs = {}
		for key, value in pairs(config.input.keys) do
			new_key_inputs[value] = key
		end
		config.input.keys = new_key_inputs
		config.input.keys.mode_exit = config.input.keys.menu_back or "escape"
	end
	if config.input.joysticks ~= nil then
		if config.input.joysticks.menu_decide ~= nil then
			local input_table = {}
			for key, binding in pairs(config.input.joysticks) do
				local joy_name = binding:sub(1, binding:find("-") - 1)
				local substring = binding:sub(binding:find("-") + 1, #binding)
				input_table[joy_name] = input_table[joy_name] or {}
				input_table[joy_name][key] = substring
			end
			config.input.joysticks = input_table
		else
			for name, joystick in pairs(config.input.joysticks) do
				if inputUpdaterConditions(joystick.buttons) and inputUpdaterConditions(joystick.axes) and inputUpdaterConditions(joystick.hats) then
					local input_table = {}
					for k2, v2 in pairs(joystick.buttons) do
						local input_str = "buttons-"..k2
						input_table[v2] = input_str
					end
					for k2, v2 in pairs(joystick.axes) do
						for k3, v3 in pairs(v2) do
							local input_str = "axes-"..k2.."-"..k3
							input_table[v3] = input_str
						end
					end
					for k2, v2 in pairs(joystick.hats) do
						for k3, v3 in pairs(v2) do
							local input_str = "hat-"..k2.."-"..k3
							input_table[v3] = input_str
						end
					end
					config.input.joysticks[name] = input_table
				end
			end
		end
	end
end
function inputVersioning()
	if not config.input.version then
		config.input.version = 1
		local keys = config.input.keys
		keys.menu_left = keys.menu_left or keys.left
		keys.menu_right = keys.menu_right or keys.right
		keys.menu_up = keys.menu_up or keys.up
		keys.menu_down = keys.menu_down or keys.down
	end
	if config.input.version < 2 then
		config.input.version = 2
		local keys = config.input.keys
		keys.tas_mode = "f1"
		keys.configure_inputs = "f2"
		keys.save_state = "f4"
		keys.load_state = "f5"
		keys.secret = "f8"
		keys.fullscreen = "f11"
		keys.screenshot = "f12"
	end
end

function initConfig()
	if not config.tunings then
		config.tunings = {
			das = config.das,
			arr = config.arr,
			dcd = config.dcd,
		}
	end
	if not config.menu_das then config.menu_das = 15 end
	if not config.menu_arr then config.menu_arr = 4 end
	if not config.master_volume then config.master_volume = 1 end
	if not config.sfx_volume then config.sfx_volume = 0.5 end
	if not config.bgm_volume then config.bgm_volume = 0.5 end

	if config.fullscreen == nil then config.fullscreen = false end
	if config.secret == nil then config.secret = false end

	if config.resource_packs_applied == nil then config.resource_packs_applied = {} end

	GameConfigScene:setDefaultConfigs()
	VisualConfigScene:setDefaultConfigs()
	AudioConfigScene:setDefaultConfigs()
	TuningScene:setDefaultConfigs()

	config.sound_sources = config.audiosettings.sound_sources

	if not config.input then
		scene = TutorialKeybinder()
	else
		if config.input.keys then
			if config.input.joysticks == nil then
				config.input.joysticks = {}
			end
			if inputUpdaterConditions(config.input.keys) or config.input.joysticks.menu_decide ~= nil then
				migrateInputConfig()
			end
			inputVersioning()
		end
		if config.current_mode then current_mode = config.current_mode end
		if config.current_ruleset then current_ruleset = config.current_ruleset end
		if config.current_folder_selections then
			current_folder_selections = config.current_folder_selections
		end
		scene = TitleScene()
		--if migrateInputConfig still fails
		if inputUpdaterConditions(config.input.keys) then
			config.input.keys = nil
			scene = InputConfigScene()
		end
	end
end

function saveConfig()
	saveToFile("config.sav", binser.serialize(config))
end

function saveHighscores()
	saveToFile(
		'highscores.sav', binser.serialize(highscores)
	)
end
