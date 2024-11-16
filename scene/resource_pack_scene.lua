local ResourcePackScene = Scene:extend()

ResourcePackScene.title = "Resource Packs"

function ResourcePackScene:new()
	config.resource_packs_applied = config.resource_packs_applied or {}
	config.resource_packs_applied[0] = nil
	self.prev_scene = scene
	self.valid_resource_packs = {}
	self.resource_pack_index = {}
	DiscordRPC:update({
		details = "In settings",
		state = "Choosing resource packs",
		largeImageKey = "settings-input"
	})
	if not love.filesystem.getInfo("resourcepacks", "directory") then
		love.filesystem.createDirectory("resourcepacks")
	end
	---@type {[...]:string}
	local resource_packs = love.filesystem.getDirectoryItems("resourcepacks")
	for key, value in pairs(resource_packs) do
		if value:sub( -4) == ".zip" and love.filesystem.getInfo("resourcepacks/" .. value, "file") then
			self.valid_resource_packs[#self.valid_resource_packs + 1] = value
			self.resource_pack_index[value] = #self.valid_resource_packs
		end
	end

	self.left_menu_height = 0
	self.left_menu_height_shift = 0
	self.right_menu_height = 0
	self.right_menu_height_shift = 0
	self.left_selection_index = 1
	self.right_selection_index = 1
	self.selection_type = 0
	self.prev_resource_packs_applied = copy(config.resource_packs_applied)
	self:refreshPackSelection()
	self.left_menu_scrollbar = newSlider(300, 220, 300, 0, 1, 0, function(value)
			self.left_menu_scrollbar_percentage = value
		end, { width = 20, orientation = "vertical" })
	self.right_menu_scrollbar = newSlider(620, 220, 300, 0, 1, 0, function(value)
			self.right_menu_scrollbar_percentage = value
		end, { width = 20, orientation = "vertical" })
end

function ResourcePackScene:refreshPackSelection()
	self.selected_resource_packs = {}
	self.unselected_resource_packs = {}
	for key, value in pairs(config.resource_packs_applied) do
		self.selected_resource_packs[#self.selected_resource_packs + 1] = value
	end
	for key, value in pairs(self.valid_resource_packs) do
		if not table.contains(config.resource_packs_applied, value) then
			self.unselected_resource_packs[#self.unselected_resource_packs + 1] = value
		end
	end
	self.unselected_resource_packs_count = #self.unselected_resource_packs
	self.selected_resource_packs_count = #self.selected_resource_packs
end

function ResourcePackScene:update()
	if self.prev_left_selection_index ~= nil and self.prev_left_selection_index ~= self.left_selection_index then
		playSE("cursor")
	end
	if self.prev_right_selection_index ~= nil and self.prev_right_selection_index ~= self.right_selection_index then
		playSE("cursor")
	end
	if self.prev_selection_type ~= nil and self.prev_selection_type ~= self.selection_type then
		playSE("cursor_lr")
	end
	local mouse_x, mouse_y = getScaledDimensions(love.mouse.getPosition())
	if self.unselected_resource_packs_count > 7 then
		self.left_menu_scrollbar:update(mouse_x, mouse_y)
	end
	if self.selected_resource_packs_count > 7 then
		self.right_menu_scrollbar:update(mouse_x, mouse_y)
	end
	if self.mouse_control then
		if self.left_menu_scrollbar_percentage and self.unselected_resource_packs_count > 7 then
			self.left_menu_height_shift = math.max(self.unselected_resource_packs_count * 40 - 280, 0) *
				self.left_menu_scrollbar_percentage
		end
		if self.right_menu_scrollbar_percentage and self.selected_resource_packs_count > 7 then
			self.right_menu_height_shift = math.max(self.selected_resource_packs_count * 40 - 280, 0) *
				self.right_menu_scrollbar_percentage
		end
	else
		if self.left_selection_index > (self.left_menu_height_shift / 40) + 6 then
			self.left_menu_height_shift = self.left_menu_height_shift + 40
		end
		if self.right_selection_index > (self.right_menu_height_shift / 40) + 6 then
			self.right_menu_height_shift = self.right_menu_height_shift + 40
		end
		if self.left_selection_index < (self.left_menu_height_shift / 40) + 1 then
			self.left_menu_height_shift = self.left_menu_height_shift - 40
		end
		if self.right_selection_index < (self.right_menu_height_shift / 40) + 1 then
			self.right_menu_height_shift = self.right_menu_height_shift - 40
		end
	end
	self.left_menu_height_shift = math.min(self.unselected_resource_packs_count * 40 - 280, self.left_menu_height_shift)
	self.right_menu_height_shift = math.min(self.selected_resource_packs_count * 40 - 280, self.right_menu_height_shift)
	self.left_menu_height_shift = math.max(self.left_menu_height_shift, 0)
	self.right_menu_height_shift = math.max(self.right_menu_height_shift, 0)
	self.left_menu_scrollbar.value = 1 -
		self.left_menu_height_shift / math.max(self.unselected_resource_packs_count * 40 - 280, 0)
	self.right_menu_scrollbar.value = 1 -
		self.right_menu_height_shift / math.max(self.selected_resource_packs_count * 40 - 280, 0)

	self.prev_left_selection_index = self.left_selection_index
	self.prev_right_selection_index = self.right_selection_index
	self.prev_selection_type = self.selection_type
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
		self:changeVerticalOption(change)
		self.das = self.das - config.menu_arr
	end
end

function ResourcePackScene:render()
	love.graphics.setColor(1, 1, 1, 1)
	drawBackground("options_input")
	local alpha = 1
	if self.selection_type ~= 1 then
		alpha = 0.5
	end
	love.graphics.setColor(1, 1, 1, alpha * fadeoutAtEdges(
		(self.left_selection_index * 40) - self.left_menu_height - 140,
		140,
		40))
	love.graphics.setLineWidth(2)
	alpha = 0.5
	love.graphics.rectangle("line", 35, 55 - self.left_menu_height + 40 * self.left_selection_index, 250, 40)
	if self.selection_type == 2 then
		alpha = 1
	end
	self.left_menu_height = interpolateNumber(self.left_menu_height, math.max(self.left_menu_height_shift, 0))
	self.right_menu_height = interpolateNumber(self.right_menu_height, math.max(self.right_menu_height_shift, 0))
	love.graphics.setColor(1, 1, 1, alpha * fadeoutAtEdges(
		(self.right_selection_index * 40) - self.right_menu_height - 140,
		140,
		40))
	love.graphics.rectangle("line", 355, 55 - self.right_menu_height + 40 * self.right_selection_index, 250, 40)
	alpha = 0.5
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.printf("Select Resource Packs", 0, 10, 640, "center")
	love.graphics.setColor(1, 1, 1, fadeoutAtEdges(
		-self.left_menu_height,
		0,
		40))
	love.graphics.printf("Available", 80, 50 - self.left_menu_height, 160, "center")
	love.graphics.printf("_________", 80, 54 - self.left_menu_height, 160, "center")
	love.graphics.setColor(1, 1, 1, fadeoutAtEdges(
		-self.right_menu_height,
		0,
		40))
	love.graphics.printf("Selected", 400, 50 - self.right_menu_height, 160, "center")
	love.graphics.printf("________", 400, 54 - self.right_menu_height, 160, "center")
	-- love.graphics.setCanvas(self.left_canvas)
	for key, value in pairs(self.unselected_resource_packs) do
		love.graphics.setColor(1, 1, 1, fadeoutAtEdges(
			-(self.left_menu_height + 140) + 40 * key,
			140,
			40))
		drawWrappingText(value, 40, 60 - self.left_menu_height + 40 * key, 240, "left")
	end
	for key, value in pairs(self.selected_resource_packs) do
		love.graphics.setColor(1, 1, 1, fadeoutAtEdges(
			-(self.right_menu_height + 140) + 40 * key,
			140,
			40))
		drawWrappingText(value, 360, 60 - self.right_menu_height + 40 * key, 240, "left")
	end

	local mouse_x, mouse_y = getScaledDimensions(love.mouse.getPosition())
	if cursorHoverArea(40, 60, 240, 320) then
		local resource_pack_index = math.floor((mouse_y + self.left_menu_height - 60) / 40)
		if resource_pack_index > 0 and resource_pack_index <= self.unselected_resource_packs_count then
			love.graphics.setColor(1, 1, 1, 0.5)
			local box_offset = self.left_menu_height - (resource_pack_index * 40)
			love.graphics.rectangle("fill", 35, 55 - box_offset, 250, 40)
			local color_highlight = cursorHighlight(260, 60-box_offset, 40, 40)
			love.graphics.setColor(1-color_highlight/2, 1-color_highlight/2, color_highlight/2, 1)
			love.graphics.polygon("fill", 260,60-box_offset, 280,75-box_offset, 260,90-box_offset)
		end
	end
	if cursorHoverArea(360, 60, 240, 320) then
		local resource_pack_index = math.floor((mouse_y + self.right_menu_height - 60) / 40)
		if resource_pack_index > 0 and resource_pack_index <= self.selected_resource_packs_count then
			love.graphics.setColor(1, 1, 1, 0.5)
			local box_offset = self.right_menu_height - (resource_pack_index * 40)
			love.graphics.rectangle("fill", 355, 55 - box_offset, 250, 40)
			local color_highlight = cursorHighlight(360, 60-box_offset, 20, 40)
			love.graphics.setColor(1-color_highlight/2, 1-color_highlight/2, color_highlight/2, 1)
			love.graphics.polygon("fill", 380,60-box_offset, 360,75-box_offset, 380,90-box_offset)
			if resource_pack_index > 1 then
				color_highlight = cursorHighlight(410, 60-box_offset, 40, 40)
				love.graphics.setColor(1-color_highlight/2, 1-color_highlight/2, color_highlight/2, 1)
				love.graphics.polygon("fill", 410,85-box_offset, 450,85-box_offset, 430,65-box_offset)
			end
			if resource_pack_index < self.selected_resource_packs_count then
				color_highlight = cursorHighlight(470, 60-box_offset, 40, 40)
				love.graphics.setColor(1-color_highlight/2, 1-color_highlight/2, color_highlight/2, 1)
				love.graphics.polygon("fill", 470,65-box_offset, 510,65-box_offset, 490,85-box_offset)
			end
		end
	end
	if self.selection_type == 3 then
		alpha = 1
	end
	love.graphics.setColor(1, 1, 1, alpha)
	alpha = 0.5
	love.graphics.rectangle("line", 80, 400, 160, 30)
	if self.selection_type == 4 then
		alpha = 1
	end
	love.graphics.setColor(1, 1, 1, alpha)
	love.graphics.rectangle("line", 400, 400, 160, 30)
	love.graphics.setLineWidth(1)

	local b = cursorHighlight(80, 400, 160, 30)
	love.graphics.setColor(1, 1, b, 1)
	love.graphics.printf("Open Pack Folder", 80, 405, 160, "center")
	b = cursorHighlight(400, 400, 160, 30)
	love.graphics.setColor(1, 1, b, 1)
	love.graphics.printf("Done", 400, 405, 160, "center")

	love.graphics.setColor(0.7, 0.7, 0.7, 1)
	if self.unselected_resource_packs_count > 7 then
		self.left_menu_scrollbar:draw()
	end
	if self.selected_resource_packs_count > 7 then
		self.right_menu_scrollbar:draw()
	end
end

function ResourcePackScene:swapSelectedPack(old_index, new_index)
	playSE("hold")
	local temp_value = config.resource_packs_applied[new_index]
	config.resource_packs_applied[new_index] = config.resource_packs_applied[old_index]
	config.resource_packs_applied[old_index] = temp_value
	self:refreshPackSelection()
end

function ResourcePackScene:exitScene()
	if equals(self.prev_resource_packs_applied, config.resource_packs_applied) then
		playSE("menu_cancel")
	else
		playSE("mode_decide")
	end
	saveConfig()
	loadResources()
	--unloading modules is kinda necessary
	unloadModules()
	scene = self.prev_scene
end

function ResourcePackScene:changeVerticalOption(rel)
	if self.selection_type == 0 then
		self.selection_type = 1
		return
	end
	
	local length = (self.selection_type == 2 and self.selected_resource_packs_count or self.unselected_resource_packs_count)
	if length < 1 then
		length = 1
	end
	if self.selection_type == 1 then
		if self.left_selection_index + rel > length then
			self.selection_type = 3
			return
		end
		self.left_selection_index = math.max(self.left_selection_index + rel, 1)
	elseif self.selection_type == 2 then
		if self.right_selection_index + rel > length then
			self.selection_type = 4
			return
		end
		self.right_selection_index = math.max(self.right_selection_index + rel, 1)
	elseif self.selection_type > 2 and rel == -1 then
		self.selection_type = self.selection_type - 2
	end
end

function ResourcePackScene:onInputPress(e)
	if e.type == "mouse" then
		self.mouse_control = true
		if cursorHoverArea(80, 400, 160, 30) then
			playSE("main_decide")
			love.system.openURL("file://" .. love.filesystem.getSaveDirectory() .. "/resourcepacks/")
		end
		if cursorHoverArea(400, 400, 160, 30) then
			self:exitScene()
		end
		if cursorHoverArea(40, 60, 240, 320) then
			local resource_pack_index = math.floor((e.y + self.left_menu_height - 60) / 40)
			if resource_pack_index > 0 and resource_pack_index <= self.unselected_resource_packs_count then
				love.graphics.setColor(1, 1, 1, 0.5)
				local box_offset = self.left_menu_height - (resource_pack_index * 40)
				love.graphics.rectangle("fill", 35, 55 - box_offset, 250, 40)
				if cursorHoverArea(260, 60-box_offset, 40, 40) then
					table.insert(config.resource_packs_applied, 1, self.unselected_resource_packs[resource_pack_index])
					self:refreshPackSelection()
				end
			end
		end
		if cursorHoverArea(360, 60, 240, 320) then
			local resource_pack_index = math.floor((e.y + self.right_menu_height - 60) / 40)
			if resource_pack_index > 0 and resource_pack_index <= self.selected_resource_packs_count then
				love.graphics.setColor(1, 1, 1, 0.5)
				local box_offset = self.right_menu_height - (resource_pack_index * 40)
				love.graphics.rectangle("fill", 355, 55 - box_offset, 250, 40)
				if cursorHoverArea(360, 60-box_offset, 20, 40) then
					table.remove(config.resource_packs_applied, resource_pack_index)
					self:refreshPackSelection()
				end
				if cursorHoverArea(410, 60-box_offset, 40, 40) and resource_pack_index > 1 then
					self:swapSelectedPack(resource_pack_index, resource_pack_index - 1)
				end
				if cursorHoverArea(470, 60-box_offset, 40, 40) and resource_pack_index < self.selected_resource_packs_count then
					self:swapSelectedPack(resource_pack_index, resource_pack_index + 1)
				end
			end
		end
	elseif e.type == "wheel" then
		self.mouse_control = true
		if cursorHoverArea(60, 60, 240, 300) and self.unselected_resource_packs_count > 7 then
			self.left_menu_scrollbar.value = self.left_menu_scrollbar.value + (e.y / self.unselected_resource_packs_count)
		end
		if cursorHoverArea(360, 60, 240, 300) and self.selected_resource_packs_count > 7 then
			self.right_menu_scrollbar.value = self.right_menu_scrollbar.value + (e.y / self.selected_resource_packs_count)
		end
	else
		self.mouse_control = false
	end
	if e.input == "hold" then
		self.hold_swap = true
	elseif e.input == "menu_decide" then
		if self.selection_type == 1 and self.unselected_resource_packs_count > 0 then
			table.insert(config.resource_packs_applied, 1, self.unselected_resource_packs[self.left_selection_index])
			self.left_selection_index = math.max(self.left_selection_index - 1, 1)
			self:refreshPackSelection()
		elseif self.selection_type == 2 and self.selected_resource_packs_count > 0 then
			table.remove(config.resource_packs_applied, self.right_selection_index)
			self.right_selection_index = math.max(self.right_selection_index - 1, 1)
			self:refreshPackSelection()
		elseif self.selection_type == 3 then
			playSE("main_decide")
			love.system.openURL("file://" .. love.filesystem.getSaveDirectory() .. "/resourcepacks/")
		end
	elseif e.input == "menu_up" then
		self:changeVerticalOption(-1)
		self.das_up = true
	elseif e.input == "menu_down" then
		self:changeVerticalOption(1)
		self.das_down = true
	elseif e.input == "menu_left" then
		if self.selection_type == 0 then
			self.selection_type = 1
			return
		end
		if self.selection_type % 2 == 0 then
			self.selection_type = self.selection_type - 1
		end
	elseif e.input == "menu_right" then
		if self.selection_type == 0 then
			self.selection_type = 1
			return
		end
		if self.selection_type % 2 == 1 then
			self.selection_type = self.selection_type + 1
		end
	end
	local prev_right_selection_index = self.right_selection_index
	if self.hold_swap and prev_right_selection_index ~= self.right_selection_index then
		local old_index = prev_right_selection_index
		local new_index = self.right_selection_index
		self:swapSelectedPack(old_index, new_index)
	end
	if e.scancode == "tab" then
		self.selection_type = Mod1(self.selection_type + 1, 4)
	end
	if e.input == "menu_back" or (self.selection_type == 4 and e.input == "menu_decide") then
		self:exitScene()
	end
end

function ResourcePackScene:onInputRelease(e)
	if e.input == "hold" then
		self.hold_swap = false
	elseif e.input == "menu_up" then
		self.das_up = false
	elseif e.input == "menu_down" then
		self.das_down = false
	end
end

return ResourcePackScene
