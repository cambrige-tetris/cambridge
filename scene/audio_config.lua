local ConfigScene = Scene:extend()

ConfigScene.title = "Audio Settings"

require 'load.save'

ConfigScene.options = {
	-- this serves as reference to what the options' values mean i guess?
	-- Option types: slider, options
	-- Format if type is options:	{name in config, displayed name, type, description, options}
	-- Format if otherwise:			{name in config, displayed name, type, description, min, max, increase by, string format, sound effect name, rounding type}
	{
		config_name = "master_volume",
		display_name = "Master Volume",
		type = "slider",
		description = "This will affect all sound sources. ALL OF IT.",
		min = 0,
		max = 100,
		increase_by = 5,
		format = "%d%%",
		sound_effect_name = "cursor"
	},
	{
		config_name = "sfx_volume",
		display_name = "SFX Volume",
		type = "slider",
		min = 0,
		max = 100,
		increase_by = 5,
		format = "%d%%",
		sound_effect_name = "cursor"
	},
	{
		config_name = "bgm_volume",
		display_name = "BGM Volume",
		type = "slider",
		min = 0,
		max = 100,
		increase_by = 5,
		format = "%d%%",
		sound_effect_name = "cursor"},
	{
		config_name = "sound_sources",
		display_name = "Simult. SFX sources",
		type = "slider",
		description = "High values may result in high memory consumption, though it allows multiples of the same sound effect to be played at once." ..
		"\n(There's some exceptions, e.g. SFX added through modes/rulesets)",
		min = 1,
		max = 30,
		increase_by = 1,
		format = "%0d",
		sound_effect_name = "cursor",
		rounding_type = "floor"
	}
}
local optioncount = #ConfigScene.options

function ConfigScene:new()
	-- load current config
	self.config = config.input
	self.highlight = 1
	self.option_pos_y = {}
	config.audiosettings.sfx_volume = config.sfx_volume * 100
	config.audiosettings.bgm_volume = config.bgm_volume * 100
	self.sliders = {
		master_volume = newSlider(320, 155, 480, config.master_volume*100, 0, 100, function(v) love.audio.setVolume(v/100) config.master_volume = v/100 config.audiosettings.master_volume = v end, {width=20, knob="circle", track="roundrect"}),
		sfx_volume = newSlider(320, 210, 480, config.sfx_volume*100, 0, 100, function(v) config.sfx_volume = v/100 config.audiosettings.sfx_volume = v end, {width=20, knob="circle", track="roundrect"}),
		bgm_volume = newSlider(320, 265, 480, config.bgm_volume*100, 0, 100, function(v) config.bgm_volume = v/100 config.audiosettings.bgm_volume = v end, {width=20, knob="circle", track="roundrect"}),
	}

	--#region Init option positions and sliders

	local y = 100
	for idx, option in ipairs(ConfigScene.options) do
		y = y + 20
		table.insert(self.option_pos_y, y)
		if option.type == "slider" then
			y = y + 35
			if config.audiosettings[option.config_name] == nil then
				config.audiosettings[option.config_name] = (option.max - option.min) / 2 + option.min
			end
			self.sliders[option.config_name] = self.sliders[option.config_name] or newSlider(320, y, 480, config.audiosettings[option.config_name], option.min, option.max, function(v) config.audiosettings[option.config_name] = math.floor(v) end, {width=20, knob="circle", track="roundrect"})
		end
	end
	--#endregion

	DiscordRPC:update({
		details = "In settings",
		state = "Changing audio settings",
	})
end

function ConfigScene:update()
	--#region Mouse
	local x, y = getScaledDimensions(love.mouse.getPosition())
	for i, slider in pairs(self.sliders) do
		slider:update(x, y)
	end
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
function ConfigScene:render()
	love.graphics.setColor(1, 1, 1, 1)
	drawBackground("options_game")

	love.graphics.setFont(font_8x11)
	love.graphics.print("AUDIO SETTINGS", 80, 43)
	local b = cursorHighlight(20, 40, 50, 30)
	love.graphics.setColor(1, 1, b, 1)
	love.graphics.printf("<-", font_3x5_4, 20, 40, 50, "center")
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(font_3x5_2)
	love.graphics.print("(THIS WILL NOT BE STORED IN REPLAYS)", 80, 80)

	love.graphics.setColor(1, 1, 1, 0.5)
	love.graphics.rectangle("fill", 25, self.option_pos_y[self.highlight] - 2, 190, 22)

	love.graphics.setFont(font_3x5_2)
	for i, option in ipairs(ConfigScene.options) do
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.printf(option.display_name, 40, self.option_pos_y[i], 170, "left")
		if option.type == "slider" then
			self:renderSlider(i, option)
		elseif option.type == "options" then
			self:renderOptions(i, option)
		end
	end
	if self.options[self.highlight].description then
		love.graphics.printf("Description: " .. self.options[self.highlight].description, 20, 400, 600, "left")
	end

	love.graphics.setColor(1, 1, 1, 0.75)
end

function ConfigScene:renderSlider(idx, option)
	love.graphics.setColor(1, 1, 1, 0.75)
	self.sliders[option.config_name]:draw()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.printf(string.format(option.format,self.sliders[option.config_name]:getValue()), 160, self.option_pos_y[idx], 320, "center")
end

function ConfigScene:renderOptions(idx, option)
	for j, setting in ipairs(option.options) do
		local b = cursorHighlight(100 + 110 * j, self.option_pos_y[idx], 100, 20)
		love.graphics.setColor(1, 1, b, config.audiosettings[option.config_name] == j and 1 or 0.5)
		love.graphics.printf(setting, 100 + 110 * j, self.option_pos_y[idx], 100, "center")
	end
end

function ConfigScene:changeValue(by)
	local option = self.options[self.highlight]
	if option.type == "slider" then
		local sld = self.sliders[option.config_name]
		sld.value = math.max(0, math.min(sld.max, (sld:getValue() + by - sld.min))) / (sld.max - sld.min)
		local x, y = getScaledDimensions(love.mouse.getPosition())
		sld:update(x, y)
	end
	if option.type == "options" then
		config.audiosettings[option.config_name] = Mod1(config.audiosettings[option.config_name]+by, #option.type)
	end
end

function ConfigScene:onInputPress(e)
	local option = self.options[self.highlight]
	if e.input == "menu_decide" or (e.type == "mouse" and e.button == 1 and e.x > 20 and e.y > 40 and e.x < 70 and e.y < 70) then
		if config.sound_sources ~= config.audiosettings.sound_sources then
			config.sound_sources = config.audiosettings.sound_sources
			--why is this necessary???
			generateSoundTable()
		end
		config.sfx_volume = config.audiosettings.sfx_volume / 100
		config.bgm_volume = config.audiosettings.bgm_volume / 100
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
		self:changeValue(-option.increase_by)
		playSE(option.sound_effect_name or "cursor_lr")
	elseif e.input == "menu_right" then
		self:changeValue(option.increase_by)
		playSE(option.sound_effect_name or "cursor_lr")
	elseif e.input == "menu_back" then
		playSE("menu_cancel")
		loadSave()
		love.audio.setVolume(config.master_volume)
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
