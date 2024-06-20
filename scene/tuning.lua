local TuningScene = Scene:extend()

TuningScene.title = "Tuning Settings"

require 'load.save'
require 'libs.simple-slider'

TuningScene.options = {
	-- Serves as a reference for the options available in the menu. Format: {name in config, name as displayed if applicable, slider name}
	{
		config_name = "das",
		display_name = "DAS",
		slider = "dasSlider"
	},
	{
		config_name = "arr",
		display_name = "ARR",
		slider = "arrSlider"
	},
	{
		config_name = "dcd",
		display_name = "DCD",
		slider = "dcdSlider"
	},
}

local optioncount = #TuningScene.options

function TuningScene:new()
	DiscordRPC:update({
		details = "In settings",
		state = "Changing tuning settings",
	})
	self.highlight = 1

	self.dasSlider = newSlider(290, 225, 400, config.das, 0, 20, function(v) config.das = math.floor(v) end, {width=20, knob="circle", track="roundrect"})
	self.arrSlider = newSlider(290, 300, 400, config.arr, 0, 6, function(v) config.arr = math.floor(v) end, {width=20, knob="circle", track="roundrect"})
	self.dcdSlider = newSlider(290, 375, 400, config.dcd, 0, 6, function(v) config.dcd = math.floor(v) end, {width=20, knob="circle", track="roundrect"})
end

function TuningScene:update()
	local x, y = getScaledDimensions(love.mouse.getPosition())
	self.dasSlider:update(x,y)
	self.arrSlider:update(x,y)
	self.dcdSlider:update(x,y)
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

function TuningScene:changeHighlight(rel)
	playSE("cursor")
	self.highlight = Mod1(self.highlight+rel, optioncount)
end

function TuningScene:render()
	love.graphics.setColor(1, 1, 1, 1)
	drawBackground("options_game")

	love.graphics.setColor(1, 1, 1, 0.5)
	love.graphics.rectangle("fill", 75, 98 + self.highlight * 75, 400, 33)

	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.setFont(font_8x11)
	love.graphics.print("TUNING SETTINGS", 80, 43)
	local b = cursorHighlight(20, 40, 50, 30)
	love.graphics.setColor(1, 1, b, 1)
	love.graphics.printf("<-", font_3x5_4, 20, 40, 50, "center")
	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.setFont(font_3x5_2)
	love.graphics.print("These settings will only apply to modes\nthat do not use their own tunings.", 80, 90)

	love.graphics.setFont(font_3x5_3)
	love.graphics.print("Delayed Auto-Shift (DAS): " .. math.floor(self.dasSlider:getValue()) .. "F", 80, 175)
	love.graphics.print("Auto-Repeat Rate (ARR): " .. math.floor(self.arrSlider:getValue()) .. "F", 80, 250)
	love.graphics.print("DAS Cut Delay (DCD): " .. math.floor(self.dcdSlider:getValue()) .. "F", 80, 325)

	love.graphics.setColor(1, 1, 1, 0.75)
	self.dasSlider:draw()
	self.arrSlider:draw()
	self.dcdSlider:draw()
end

function TuningScene:onInputPress(e)
	if e.type == "mouse" then
		if e.x > 20 and e.y > 40 and e.x < 70 and e.y < 70 then
			playSE("mode_decide")
			saveConfig()
			scene = SettingsScene()
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
		playSE("cursor")
		local sld = self[self.options[self.highlight].slider]
		sld.value = math.max(sld.min, math.min(sld.max, (sld:getValue() - 1) / (sld.max - sld.min)))
	elseif e.input == "menu_right" then
		playSE("cursor")
		local sld = self[self.options[self.highlight].slider]
		sld.value = math.max(sld.min, math.min(sld.max, (sld:getValue() + 1) / (sld.max - sld.min)))
	elseif e.input == "menu_back" then
		playSE("menu_cancel")
		loadSave()
		scene = SettingsScene()
	end
end

function TuningScene:onInputRelease(e)
	if e.input == "menu_up" then
		self.das_up = false
	elseif e.input == "menu_down" then
		self.das_down = false
	end
end

return TuningScene