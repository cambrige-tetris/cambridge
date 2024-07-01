local TitleScene = Scene:extend()

TitleScene.title = "Title"
TitleScene.restart_message = false

local enter_pressed = not (config and config.input)
local menu_frames = 0

TitleScene.menu_screens = {
	ModeSelectScene,
	HighscoresScene,
	ReplaySelectScene,
	JoinDiscordFunc,
	ReportBugFunc,
	SettingsScene,
	CreditsScene,
	ExitScene,
}

local mainmenuidle = {
	"Idle",
	"On title screen",
	"On main menu screen",
	"Twiddling their thumbs",
	"Admiring the main menu's BG",
	"Waiting for spring to come",
	"Actually not playing",
	"Contemplating collecting stars",
	"Preparing to put the block!!",
	"Having a nap",
	"In menus",
	"Bottom text",
	"Trying to see all the funny rpc messages (maybe)",
	"Not not not playing",
	"AFK",
	"Preparing for their next game",
	"Who are those people on that boat?",
	"Welcome to Cambridge!",
	"who even reads these",
	"Made with love in LOVE!",
	"This is probably the longest RPC string out of every possible RPC string that can be displayed."
}

function TitleScene:new()
	self.love2d_major, self.love2d_minor, self.love2d_revision = love.getVersion()
	self.main_menu_state = 1
	self.frames = 0
	self.snow_bg_opacity = 0
	self.y_offset = 0
	self.press_enter_text = "Press Enter"
	self.joystick_names = {}
	self.joystick_menu_decide_binds = {}
	if config and config.input then
		if config.input.keys then
			if not (
				config.input.keys.menu_decide == nil or
				config.input.keys.menu_decide == "return" or
				config.input.keys.menu_decide == "kpenter"
			) then
				self.press_enter_text = self.press_enter_text.." or [" .. config.input.keys.menu_decide .. "] key"
			end
		end
	end
	self.text = ""
	self.text_flag = false
	if config.visualsettings.mode_select_type == 1 then
		TitleScene.menu_screens[1] = ModeSelectScene
	else
		TitleScene.menu_screens[1] = RevModeSelectScene
	end
	DiscordRPC:update({
		details = "In menus",
		state = mainmenuidle[love.math.random(#mainmenuidle)],
		largeImageKey = "icon2",
		largeImageText = version
	})
	self.das = 0
end

function TitleScene:update()
	if self.text_flag then
		self.frames = self.frames + 1
		self.snow_bg_opacity = self.snow_bg_opacity + 0.01
	end
	if enter_pressed then
		menu_frames = menu_frames + 1
	end
	if self.frames < 125 then self.y_offset = self.frames
	elseif self.frames < 185 then self.y_offset = 125
	else self.y_offset = 310 - self.frames end
	if self.das_up or self.das_down then
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
		self:changeOption(change)
		self.das = self.das - 4

	end
end

local block_offsets = {
	{color = "M", x = 0, y = 0},
	{color = "G", x = 32, y = 0},
	{color = "Y", x = 64, y = 0},
	{color = "B", x = 0, y = 32},
	{color = "O", x = 0, y = 64},
	{color = "C", x = 32, y = 64},
	{color = "R", x = 64, y = 64}
}

function TitleScene:render()
	love.graphics.setFont(font_3x5_4)
	love.graphics.setColor(1, 1, 1, 1 - self.snow_bg_opacity)
	drawBackground("title_no_icon") -- title, title_night

	love.graphics.setColor(1, 1, 1, 1)
	if not enter_pressed then
		love.graphics.setFont(font_3x5_3)
		love.graphics.printf("Welcome To Cambridge: The Next Open-Source Stacker!", 0, 240, 640, "center")
		if love.timer.getTime() % 2 <= 1 then
			love.graphics.printf(self.press_enter_text, 80, 360, 480, "center")
		end
		love.graphics.setFont(font_3x5_2)
		if not (self.love2d_major == 11 and (self.love2d_minor == 3 or self.love2d_minor == 5)) and not (self.love2d_major == 12 and self.love2d_minor == 0) then
			love.graphics.printf({{1, 0, 0, 1}, ("LOVE %d.%d is a potentially unstable version for Cambridge in other OS such as macOS or Linux at the moment! Stick to 11.3 or 11.5 for now."):format(self.love2d_major, self.love2d_minor)}, 50, 60, 540, "center")
		elseif (self.love2d_major == 12 and self.love2d_minor == 0) then
			love.graphics.printf({{1, 1, 0, 1}, "Currently LOVE 12.0 is in development. Expect there be more bugs. Cambridge currently doesn't utilise the new features at the moment."}, 50, 60, 540, "center")
		end
		love.graphics.printf("This new version has a lot of changes, so expect that there'd be a lot of bugs!\nReport bugs and issues found here to cambridge-stacker repository, in detail.", 0, 280, 640, "center")
	end
	local x, y
	if enter_pressed then
		x, y = 490, 192
	else
		x, y = 272, 140
	end
	for _, b in ipairs(block_offsets) do
		drawSizeIndependentImage(
			blocks["2tie"][b.color],
			x + b.x, y + b.y, 0,
			32, 32
		)
	end

	--[[
	love.graphics.draw(
		misc_graphics["icon"],
		490, 192, 0,
		2, 2
	)
	]]
	--love.graphics.printf("Thanks for 1 year!", 430, 280, 160, "center")

	love.graphics.setFont(font_3x5_2)
	love.graphics.setColor(1, 1, 1, self.snow_bg_opacity)
	drawBackground("snow")

	love.graphics.draw(
		misc_graphics["santa"],
		400, -205 + self.y_offset,
		0, 0.5, 0.5
	)
	love.graphics.print("Happy Holidays!", 320, -100 + self.y_offset)

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print(self.restart_message and "Restart Cambridge..." or "", 0, 0)

	if not enter_pressed then
		return
	end

	love.graphics.setColor(1, 1, 1, 0.5)
	love.graphics.rectangle("fill", math.min(20, -120 * self.main_menu_state + (menu_frames * 24) - 20), 278 + 20 * self.main_menu_state, 160, 22)

	love.graphics.setColor(1, 1, 1, 1)
	for i, screen in pairs(self.menu_screens) do
		local b = cursorHighlight(40,280 + 20 * i,120,20)
		love.graphics.setColor(1,1,b,1)
		love.graphics.printf(screen.title, math.min(40, -120 * i + (menu_frames * 24)), 280 + 20 * i, 120, "left")
	end
end

function TitleScene:changeOption(rel)
	local len = #self.menu_screens
	self.main_menu_state = (self.main_menu_state + len + rel - 1) % len + 1
	playSE("cursor")
end

function TitleScene:onInputPress(e)
	if not enter_pressed then
		if e.scancode == "return" or e.scancode == "kpenter" or e.input == "menu_decide" then
			enter_pressed = true
			playSE("main_decide")
		elseif e.input == "menu_back" or e.scancode == "backspace" or e.scancode == "delete" then
			love.event.quit()
		end
		return
	end
	if e.type == "mouse" and menu_frames > 10 * #self.menu_screens then
		if e.x > 40 and e.x < 160 then
			if e.y > 300 and e.y < 300 + #self.menu_screens * 20 then
				self.main_menu_state = math.floor((e.y - 280) / 20)
				playSE("main_decide")
				scene = self.menu_screens[self.main_menu_state]()
			end
		end
	end
	if e.input == "menu_decide" then
		playSE("main_decide")
		scene = self.menu_screens[self.main_menu_state]()
	elseif e.input == "menu_up" then
		self:changeOption(-1)
		self.das_up = true
	elseif e.input == "menu_down" then
		self:changeOption(1)
		self.das_down = true
	elseif e.input == "menu_back" or e.scancode == "backspace" or e.scancode == "delete" then
		love.event.quit()
	else
		self.text = self.text .. (e.scancode or "")
		if self.text == "ffffff" then
			self.text_flag = true
			DiscordRPC:update({
				largeImageKey = "snow"
			})
		end
	end
end

function TitleScene:onInputRelease(e)
	if e.input == "menu_up" then
		self.das_up = false
	elseif e.input == "menu_down" then
		self.das_down = false
	end
end

return TitleScene
