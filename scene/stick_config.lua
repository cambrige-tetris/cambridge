local StickConfigScene = Scene:extend()

StickConfigScene.title = "Joystick Config"

require 'load.save'

local configurable_inputs = {
	"menu_decide",
	"menu_back",
	"left",
	"right",
	"up",
	"down",
	"rotate_left",
	"rotate_left2",
	"rotate_right",
	"rotate_right2",
	"rotate_180",
	"hold",
	"retry",
	"pause",
	"mode_exit",
	"frame_step",
	"generic_1",
	"generic_2",
	"generic_3",
	"generic_4",
}

local input_naming = {
	menu_decide = "Menu Decide",
	menu_back = "Menu Back",
	left = "Generic Left",
	right = "Generic Right",
	up = "Generic Up",
	down = "Generic Down",
	rotate_left = "Rotate CCW [1]",
	rotate_left2 = "Rotate CCW [2]",
	rotate_right = "Rotate CW [1]",
	rotate_right2 = "Rotate CW [2]",
	rotate_180 = "Rotate 180",
	hold = "Hold",
	retry = "Retry",
	pause = "Pause",
	mode_exit = "Exit Mode",
	frame_step = "Frame Step",
	generic_1 = "Generic 1",
	generic_2 = "Generic 2",
	generic_3 = "Generic 3",
	generic_4 = "Generic 4",
}

--A list of inputs that shouldn't have the same keybinds with the other.
local mutually_exclusive_inputs = {
	menu_decide = "menu_back",
	mode_exit = {"retry", "pause"},
	pause = {"mode_exit", "retry"},
	retry = {"mode_exit", "pause"},
	left = {"right", "up", "down"},
	right = {"left", "up", "down"},
	up = {"down", "left", "right"},
	down = {"left", "up", "right"},
	menu_left = {"menu_right", "menu_up", "menu_down"},
	menu_right = {"menu_left", "menu_up", "menu_down"},
	menu_up = {"menu_down", "menu_left", "menu_right"},
	menu_down = {"menu_left", "menu_up", "menu_right"},
}

function StickConfigScene:mutexCheck(input, binding)
	for key, value in pairs(mutually_exclusive_inputs) do
		if key == input then
			if type(value) == "table" then
				for k2, v2 in pairs(value) do
					if self.new_input[v2] == binding then
						return true, v2
					end
				end
			end
			if self.new_input[value] == binding then
				return true, value
			end
		elseif value == input then
			if self.new_input[key] == binding then
				return true, key
			end
		end
	end
	return false
end

local function newSetInputs()
	local set_inputs = {}
	for i, input in ipairs(configurable_inputs) do
		set_inputs[input] = false
	end
	return set_inputs
end

local null_joystick_name = ""

function StickConfigScene:new()
	self.input_state = 1
	self.erase_timer = -1
	self.set_inputs = newSetInputs()
	self.new_input = {}
	self.axis_timer = 0
	self.joystick_name = null_joystick_name

	self.list_y = 0
	self.final_list_y = 0
	self.spacing = 18

	if not config.input then config.input = {} end

	self.safety_frames = 0
	self.error_time = 0

	DiscordRPC:update({
		details = "In settings",
		state = "Changing joystick config",
	})
end

local directions = {
	["u"] = "up",
	["d"] = "down",
	["l"] = "left",
	["r"] = "right",
}

--too many impl details and substrings
function StickConfigScene.formatBinding(binding)
	local substring = binding:sub(binding:find("-") + 1, #binding)
	local mid_substring = binding:sub(1, binding:find("-") - 1)
	if mid_substring == "buttons" then
		return "Button " .. substring
	elseif mid_substring == "hat" then
		local secondmid_substring = substring:sub(1, substring:find("-") - 1)
		local second_substring = substring:sub(substring:find("-") + 1)
		return "Hat " ..
		secondmid_substring .. " " .. (directions[second_substring] or second_substring)
	elseif mid_substring == "axes" then
		local second_substring = substring:sub(1, substring:find("-") - 1)
		return "Axis " ..
		(substring:sub(substring:find("-") + 1) == "positive" and "+" or "-") .. second_substring
	end
	return "Missing"
end

function StickConfigScene:update()
	self.safety_frames = self.safety_frames - 1
	self.error_time = self.error_time - love.timer.getDelta()
	if self.final_list_y / self.spacing > self.input_state - 5 then
		self.final_list_y = (self.input_state - 5) * self.spacing
	end
	if self.final_list_y / self.spacing < self.input_state - 15 then
		self.final_list_y = (self.input_state - 15) * self.spacing
	end
	self.final_list_y = math.max(self.final_list_y, 0)
	if self.das_up or self.das_down then
		self.das = self.das + 1
	else
		self.das = 0
	end
	if self.das >= config.menu_das then
		local change = 0
		if self.das_up then
			change = -1
		elseif self.das_down then
			change = 1
		end
		playSE("cursor")
		self.input_state = Mod1(self.input_state + change, #configurable_inputs)
		self.das = self.das - config.menu_arr
	end
end

function StickConfigScene:render()
	love.graphics.setColor(1, 1, 1, 1)
	drawBackground("options_input")

	love.graphics.setFont(font_8x11)
	love.graphics.print("JOYSTICK CONFIG", 80, 43)

	local b = cursorHighlight(20, 40, 50, 30)
	love.graphics.setColor(1, 1, b, 1)
	love.graphics.setFont(font_3x5_4)
	love.graphics.printf("<-", 20, 40, 50, "center")
	love.graphics.setColor(1, 1, 1, 1)

	if self.joystick_name == null_joystick_name then
		love.graphics.setFont(font_3x5_3)
		love.graphics.printf("Interact with a joystick to map inputs.", 160, 240, 320, "center")
	end
	self.list_y = interpolateNumber(self.list_y, -self.final_list_y)
	love.graphics.setFont(font_3x5_2)
	for i, input in ipairs(configurable_inputs) do
		local g, b = 1, 1
		local alpha = fadeoutAtEdges(self.list_y + (i-1) * self.spacing - 180, 180, self.spacing)
		if self.joystick_name == null_joystick_name then
			alpha = alpha / 2
		end
		if i == self.input_state then
			b = 0
			if self.error_time > 0 then
				g = 0
			end
		end
		love.graphics.setColor(1, 1, b, alpha)
		love.graphics.printf(input_naming[input] or "null", 40, self.list_y + 70 + i * self.spacing, 200, "left")
		
		love.graphics.setColor(1, g, g, alpha)
		if self.set_inputs[input] then
			love.graphics.printf(self.set_inputs[input], 240, self.list_y + 70 + i * self.spacing, 400, "left")
		end
	end
	if self.joystick_name == null_joystick_name then
		return
	end
	if self.erase_timer == 0 then
		self:rebind(nil)
		self.rebinding = false
	elseif self.erase_timer == 30 then
		self.set_inputs[configurable_inputs[self.input_state]] = "<erasing binding...>"
	end
	if self.erase_timer >= 0 then
		self.erase_timer = self.erase_timer - 1
	end
	if self.input_state > #configurable_inputs then
		love.graphics.print("Press enter to confirm, delete/backspace to retry" .. (config.input and ", escape to cancel" or ""))
		return
	elseif self.reconfiguration and not self.rebinding then
		love.graphics.printf("Press escape or ".. self.formatBinding(config.input.joysticks[self.joystick_name].menu_decide) .." to exit and save, Up or Down to move selection.", 0, 0, 640, "left")
	elseif self.rebinding or not self.reconfiguration then
		local tab_string = self.reconfiguration and "erase" or "skip"
		love.graphics.printf("Press tab key on keyboard, or hold for 1 second to ".. tab_string ..".", 0, 0, 640, "left")
	end

	self.axis_timer = self.axis_timer + 1
end

function StickConfigScene:rebind(binding)
	local input_type = configurable_inputs[self.input_state]
	if binding == nil then
		self.new_input[input_type] = nil
		self.set_inputs[input_type] = "erased"
		return true
	end
	local is_invalid, existing_bind = self:mutexCheck(input_type, binding)
	if is_invalid then
		self.set_inputs[input_type] = ("<%s conflicts with %s>"):format(self.formatBinding(binding), input_naming[existing_bind])
		self.error_time = buffer_sounds.error[1]:getDuration("seconds") or 0.5
		return false
	end
	self.set_inputs[input_type] = self.formatBinding(binding)
	self.new_input[input_type] = binding
	if input_type == "left" or input_type == "right" or input_type == "up" or input_type == "down" then
		self.new_input["menu_"..input_type] = binding
	end
	return true
end

local function addJoystick(input, name)
	if not input[name] then
		input[name] = {}
	end
end

function StickConfigScene:onInputPress(e)
	if e.type == "mouse" then
		if cursorHoverArea(20, 40, 50, 30) then
			playSE("menu_cancel")
			scene = InputConfigScene()
		end
	end
	if self.safety_frames > 0 then
		return
	end
	if e.input == "menu_back" and (self.type == "key" or not self.rebinding) then
		if self.reconfiguration then
			self.new_input.menu_left = self.new_input.left
			self.new_input.menu_right = self.new_input.right
			self.new_input.menu_up = self.new_input.up
			self.new_input.menu_down = self.new_input.down
			config.input.joysticks[self.joystick_name] = self.new_input
			saveConfig()
		end
		playSE("menu_cancel")
		scene = InputConfigScene()
	elseif e.input and self.joystick_name ~= null_joystick_name and (self.type == "key" or not self.rebinding) then
		-- function keys, escape, and tab are reserved and can't be remapped
		if self.input_state > #configurable_inputs then
			if e.scancode == "return" or e.input == "menu_decide" then
				-- save new input, then load next scene
				local had_config = config.input ~= nil
				if not config.input then config.input = {} end
				config.input.joysticks[self.joystick_name] = self.new_input
				saveConfig()
				scene = had_config and InputConfigScene() or TitleScene()
			elseif e.scancode == "delete" or e.scancode == "backspace" then
				-- retry
				self.input_state = 1
				self.set_inputs = newSetInputs()
				self.new_input = {}
			end
		elseif self.reconfiguration then
			if self.rebinding then
				if e.scancode == "tab" then
					self:rebind(nil) --this is done on purpose
					self.rebinding = false
					self.safety_frames = 2
				end
			else
				if e.input == "menu_up" or e.direction == "u" then
					playSE("cursor")
					self.input_state = Mod1(self.input_state - 1, #configurable_inputs)
					self.das_up = true
					self.safety_frames = 2
				elseif e.input == "menu_down" or e.direction == "d" then
					playSE("cursor")
					self.input_state = Mod1(self.input_state + 1, #configurable_inputs)
					self.das_down = true
					self.safety_frames = 2
				elseif e.input == "menu_decide" then
					playSE("main_decide")
					self.set_inputs[configurable_inputs[self.input_state]] = "<release to start binding, or hold to erase>"
					self.rebinding = true
					self.erase_timer = 60
					self.safety_frames = 2
				end
			end
		elseif e.scancode == "tab" then
			self.set_inputs[configurable_inputs[self.input_state]] = "skipped"
			self.input_state = self.input_state + 1
		end
	elseif string.sub(e.type, 1, 3) == "joy" then
		if self.joystick_name == null_joystick_name then
			self.safety_frames = 2
			self.joystick_name = e.name
			if config.input.joysticks[e.name] == nil then
				config.input.joysticks[e.name] = {}
			end
			self.reconfiguration = true
			self.new_input = config.input.joysticks[e.name]
			for input_name, binding in pairs(config.input.joysticks[e.name]) do
				self.set_inputs[input_name] = self.formatBinding(binding)
			end
			return
		end
		if self.input_state <= #configurable_inputs and (not self.reconfiguration or self.rebinding) then
			self.safety_frames = 2
			if e.type == "joybutton" then
				local input_result = "buttons-" .. e.button
				if self:rebind(input_result) then
					playSE("mode_decide")
					self.rebinding = false
				else
					playSE("error")
				end
				if not self.reconfiguration then
					self.input_state = self.input_state + 1
				end
			elseif e.type == "joyaxis" then
				if (e.axis ~= self.last_axis or self.axis_timer > 30) and math.abs(e.value) >= 1 then

					local input_result = "axes-" .. e.axis .. "-" .. (e.value >= 1 and "positive" or "negative")
					if self:rebind(input_result) then
						playSE("mode_decide")
						self.rebinding = false
					else
						playSE("error")
					end
					if not self.reconfiguration then
						self.input_state = self.input_state + 1
						self.set_inputs[configurable_inputs[self.input_state]] = "<provide joystick input>"
					end
					self.last_axis = e.axis
					self.axis_timer = 0
				end
			elseif e.type == "joyhat" then
				if e.direction ~= "c" then
					local input_result = "hat-" .. e.hat .. "-" .. e.direction
					if self:rebind(input_result) then
						playSE("mode_decide")
						self.rebinding = false
					else
						playSE("error")
					end
					if not self.reconfiguration then
						self.input_state = self.input_state + 1
						self.set_inputs[configurable_inputs[self.input_state]] = "<provide joystick input>"
					end
				end
			end
		end
	end
end

function StickConfigScene:onInputRelease(e)
	if e.input == "menu_up" or e.direction == "u" then
		self.das_up = false
	elseif e.input == "menu_down" or e.direction == "d" then
		self.das_down = false
	elseif e.input == "menu_decide" and self.rebinding then
		self.set_inputs[configurable_inputs[self.input_state]] = "<provide joystick input>"
		self.erase_timer = -1
	end
end

return StickConfigScene
