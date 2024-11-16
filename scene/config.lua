local ConfigScene = Scene:extend()

ConfigScene.title = "Generic Settings"
ConfigScene.config_type = "generic"

require 'load.save'
require 'libs.simple-slider'

---@class settings_config_option
---@field config_name string
---@field display_name string
---@field description string?
---@field options table?
---@field default number
---@field increase_by number?
---@field min number?
---@field max number?
---@field format string|function?
---@field sound_effect_name string?
---@field setter function?
---@field type "slider"|"options"|"number"
local config_option

---@type settings_config_option[]
ConfigScene.options = {
	-- Option types: slider, options, number
	-- Format if type is options:	{name in config, displayed name, type, description, default, options}
	-- Format if otherwise:      	{name in config, displayed name, type, description, default, min, max, increase by, string format, sound effect name, setter function}
}

function ConfigScene:setDefaultConfigs()
	if not config[self.config_type] then config[self.config_type] = {} end
	for key, option in pairs(self.options) do
		if config[self.config_type][option.config_name] == nil then
			if option.setter then
				option.setter(option.default)
			else
				config[self.config_type][option.config_name] = option.default
			end
		end
	end
end

function ConfigScene:new(width)
	self.highlight = 1
	self.options_width = width or 150
	self.option_pos_y = {}

	--#region Init option positions and sliders

	self.sliders = {}
	local y = 100
	for idx, option in ipairs(self.options) do
		option.increase_by = option.increase_by or 1
		y = y + (self.spacing or 20)
		table.insert(self.option_pos_y, y)
		assert((option.min or 0) < (option.max or 1), "the min value is higher than max value!")
		if option.type == "slider" then
			self.sliders[option.config_name] = newSlider(350 + (self.options_width / 2), y + 9,
			450 - (self.options_width / 2), config[self.config_type][option.config_name], option.min, option.max,
			option.setter or function (v) config[self.config_type][option.config_name] = v end,
			{width=20, knob="circle", track="roundrect"})
		end
	end
	--#endregion

	self.vertical_das = 0
	self.horizontal_das = 0

	DiscordRPC:update({
		details = "In settings",
		state = "Changing settings",
	})
end

function ConfigScene:update()
	--#region Mouse
	local x, y = getScaledDimensions(love.mouse.getPosition())
	for i, slider in pairs(self.sliders) do
		slider:update(x, y)
	end
	--#endregion
	if self.das_up or self.das_down then
		self.vertical_das = self.vertical_das + 1
	else
		self.vertical_das = 0
	end
	if self.das_left or self.das_right then
		self.horizontal_das = self.horizontal_das + 1
	else
		self.horizontal_das = 0
	end
	if self.vertical_das >= config.menu_das then
		local change = 0
		if self.das_up then
			change = -1
		elseif self.das_down then
			change = 1
		end
		self:changeHighlight(change)
		self.vertical_das = self.vertical_das - config.menu_arr
	end
	if self.horizontal_das >= config.menu_das then
		local highlighted_option = self.options[self.highlight]
		if self.das_left then
			self:changeValue(-highlighted_option.increase_by)
		elseif self.das_right then
			self:changeValue(highlighted_option.increase_by)
		end
		self.horizontal_das = self.horizontal_das - config.menu_arr
	end
end

function ConfigScene:changeHighlight(rel)
	playSE("cursor")
	self.highlight = Mod1(self.highlight+rel, #self.options)
end

function ConfigScene:renderSettings()
	local b = cursorHighlight(20, 40, 50, 30)
	love.graphics.setColor(1, 1, b, 1)
	love.graphics.printf("<-", font_3x5_4, 20, 40, 50, "center")

	love.graphics.setColor(1, 1, 1, 0.5)
	love.graphics.rectangle("fill", 25, self.option_pos_y[self.highlight] - 2, self.options_width + 20, 22)

	love.graphics.setFont(font_3x5_2)
	for i, option in ipairs(self.options) do
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.printf(option.display_name, 40, self.option_pos_y[i], self.options_width, "left")
		if option.type == "slider" then
			self:drawSlider(i, option)
		elseif option.type == "options" then
			self:drawOptions(i, option)
		elseif option.type == "number" then
			self:drawNumber(i, option)
		end
	end
	if self.options[self.highlight].description then
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.printf("Description: " .. self.options[self.highlight].description, 20, 380, 600, "left")
	end
end

function ConfigScene:drawSlider(idx, option)
	love.graphics.setColor(1, 1, 1, 0.75)
	self.sliders[option.config_name]:draw()
	self:drawNumber(idx, option)
end

function ConfigScene:drawNumber(idx, option)
	local pos_x = 90 + self.options_width
	local width = 510 - self.options_width
	love.graphics.setColor(1, 1, 1, 1)
	local formatted_string = option
	if type(option.format) == "function" then
		formatted_string = option.format(config[self.config_type][option.config_name])
	elseif type(option.format) == "string" then
		formatted_string = string.format(option.format, config[self.config_type][option.config_name])
	end
	love.graphics.printf(formatted_string, pos_x, self.option_pos_y[idx], width, "center")
end

function ConfigScene:drawOptions(idx, option)
	local initial_pos_x = self.options_width - 50
	for j, setting in ipairs(option.options) do
		local b = cursorHighlight(initial_pos_x + 110 * j, self.option_pos_y[idx], 100, 20)
		love.graphics.setColor(1, 1, b, config[self.config_type][option.config_name] == j and 1 or 0.5)
		love.graphics.printf(setting, initial_pos_x + 110 * j, self.option_pos_y[idx], 100, "center")
	end
end

function ConfigScene:changeValue(by)
	local option = self.options[self.highlight]
	if option.type == "slider" then
		local sld = self.sliders[option.config_name]
		sld.value = math.max(0, math.min(sld.max, (sld:getValue() + by - sld.min))) / (sld.max - sld.min)
		local x, y = getScaledDimensions(love.mouse.getPosition())
		sld:update(x, y)
	elseif option.type == "options" then
		config[self.config_type][option.config_name] = Mod1(config[self.config_type][option.config_name]+by, #option.options)
	else
		local new_value = Mod1(config[self.config_type][option.config_name] + by-option.min, option.max - option.min) + option.min
		if option.setter then
			option.setter(new_value)
		else
			config[self.config_type][option.config_name] = new_value
		end
	end
	playSE(option.sound_effect_name or "cursor_lr")
end

function ConfigScene:onConfirm() end

function ConfigScene:onCancel() end

function ConfigScene:onInputPress(e)
	local highlighted_option = self.options[self.highlight]
	if e.input == "menu_decide" then
		playSE("mode_decide")
		self:onConfirm()
		saveConfig()
		scene = SettingsScene()
	elseif e.type == "mouse" and e.button == 1 then
		for i, option in ipairs(self.options) do
			if option.type == "options" then
				local initial_pos_x = self.options_width - 50
				for j, setting in ipairs(option.options) do
					if cursorHoverArea(initial_pos_x + 110 * j, self.option_pos_y[i], 90, 20) then
						self.main_menu_state = i
						playSE(option.sound_effect_name or "cursor_lr")
						config[self.config_type][option.config_name] = Mod1(j, #option.options)
					end
				end
			end
		end
		if cursorHoverArea(20, 40, 50, 30) then
			playSE("mode_decide")
			self:onConfirm()
			saveConfig()
			scene = SettingsScene()
		end
	elseif e.input == "menu_up" then
		self:changeHighlight(-1)
		self.das_up = true
	elseif e.input == "menu_down" then
		self:changeHighlight(1)
		self.das_down = true
	elseif e.input == "menu_left" then
		self:changeValue(-highlighted_option.increase_by)
		self.das_left = true
	elseif e.input == "menu_right" then
		self:changeValue(highlighted_option.increase_by)
		self.das_right = true
	elseif e.input == "menu_back" then
		playSE("menu_cancel")
		loadSave()
		self:onCancel()
		scene = SettingsScene()
	end
end

function ConfigScene:onInputRelease(e)
	if e.input == "menu_up" then
		self.das_up = false
	elseif e.input == "menu_down" then
		self.das_down = false
	elseif e.input == "menu_left" then
		self.das_left = false
	elseif e.input == "menu_right" then
		self.das_right = false
	end
end

return ConfigScene
