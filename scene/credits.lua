local CreditsScene = Scene:extend()

CreditsScene.title = "Credits"

function CreditsScene:new()
	self.time = 0
	-- higher = faster
	self.scroll_speed = 1
	pitchBGM(1)
	switchBGM("credit_roll", "gm3")

	DiscordRPC:update({
		details = "Watching the credits",
		state = "Thanks for playing the game!",
		largeImageKey = "ingame-1900",
	})
	self.credit_blocks = {
		{
			title = "Game Developers",
			"Oshisaure",
			"Joe Zeng",
			"MillaBasset",
			"Tetro48",
		},
		{
			title = "Project Heads",
			"Mizu",
			"MarkGamed",
			"Hailey",
		},
		{
			title = "Notable Game Developers",
			"2Tie - TGMsim",
			"Axel Fox - Multimino",
			"Dr Ocelot - Tetra Legends",
			"Electra - ZTrix",
			"Felicity/nightmareci/kdex - Shiromino",
			"Mine - Tetra Online",
			"MrZ - Techmino",
			"Phoenix Flare - Master of Blocks",
			"RayRay26 - Spirit Drop",
		},
		{
			title = "Special Thanks",
			"321MrHaatz",
			"Adventium",
			"AgentBasey",
			"Archina",
			"Aurora",
			"Caithness",
			"Cheez",
			"colour_thief",
			"Commando",
			"Cublex",
			"CylinderKnot",
			"eightsixfivezero",
			"EricICX",
			"Gesomaru",
			"gizmo4487",
			"JBroms",
			"Kirby703",
			"Kitaru",
			"M1ssing0",
			"MattMayuga",
			"MyPasswordIsWeak",
			"Nikki Karissa",
			"nim",
			"offwo",
			"Oliver",
			"Pineapple",
			"pokemonfan1937",
			"Pyra Neoxi",
			"RDST64",
			"RocketLanterns",
			"RustyFoxxo",
			"saphie",
			"Shelleloch",
			"Simon",
			"stratus",
			"Super302",
			"switchpalacecorner",
			"terpyderp",
			"Tetrian22",
			"ThatCookie",
			"TimmSkiller",
			"Trixciel",
			"user74003",
			"ZaptorZap",
			"Zircean",
			"All other contributors and friends!",
			"The Absolute PLUS Discord",
			"Tetra Legends Discord",
			"Tetra Online Discord",
			"Multimino Discord",
			"Hard Drop Discord",
			"Rusty's Systemspace",
			"Cambridge Discord",
			"And to you, the player!"
		},
	}
	local y_calculation = 550
	for key, value in pairs(self.credit_blocks) do
		value.y = y_calculation
		y_calculation = y_calculation + (#value * 18) + 80
	end
	self.final_y = y_calculation + 120
	if bgm.credit_roll and bgm.credit_roll.gm3 then
		self.music_duration = bgm.credit_roll.gm3:getDuration("seconds") * 60 - 120
	else
		self.music_duration = 4000
	end
	self.hold_speed = math.max(2, math.floor(self.music_duration / 600))
end

function CreditsScene:update()
	if self.increase_speed then
		self.scroll_speed = interpolateNumber(self.scroll_speed, self.hold_speed, 8)
	else
		self.scroll_speed = interpolateNumber(self.scroll_speed, 1, 8)
	end
	pitchBGM(self.scroll_speed)
	local time_fragment = (self.final_y / self.music_duration)
	self.time = self.time + (time_fragment * self.scroll_speed) * (getDeltaTime()*60)
	if self.time >= self.final_y + (time_fragment * 120) then
		playSE("mode_decide")
		scene = TitleScene()
		pitchBGM(1)
		switchBGM(nil)
	elseif self.time >= self.final_y then
		fadeoutBGM(2)
	end
end

local alignment_table = {"right", "center", "left"}

local alignment_coordinates = {320, 160}

function CreditsScene:render()
	local offset = self.time

	local credits_pos = config.visualsettings.credits_position

	local text_x = alignment_coordinates[credits_pos]

	local align = alignment_table[4-credits_pos]

	love.graphics.setColor(1, 1, 1, 1)
	drawBackground(19)

	love.graphics.setFont(font_3x5_4)
	love.graphics.printf("Cambridge Credits", text_x, 500 - offset, 320, align)
	love.graphics.setFont(font_3x5_3)
	love.graphics.printf("THANK YOU FOR PLAYING!", text_x, math.max(self.final_y - offset, 240), 320, align)

	for index, block in ipairs(self.credit_blocks) do
		love.graphics.setFont(font_3x5_3)
		love.graphics.printf(block.title, text_x, block.y - offset, 320, align)
		love.graphics.setFont(font_3x5_2)
		for key, value in ipairs(block) do
			love.graphics.printf(value, text_x, block.y + 30 + key * 18 - offset, 320, align)
		end
	end
	love.graphics.print(("Credit time: %.2fs / %.2fs, %.1fx"):format((self.time / (self.final_y / self.music_duration)) / 60, (self.final_y + ((self.final_y / self.music_duration) * 120)) / (self.final_y / self.music_duration) / 60, self.scroll_speed), 0, 460)
end

function CreditsScene:onInputPress(e)
	if e.type == "mouse" then
		if e.button == 1 then
			self.increase_speed = true
		elseif e.button == 2 then
			scene = TitleScene()
			pitchBGM(1)
			switchBGM(nil)
		end
	end
	if e.scancode == "space" then
		self.increase_speed = true
	end
	if e.input == "menu_decide" or e.input == "menu_back" then
		scene = TitleScene()
		pitchBGM(1)
		switchBGM(nil)
	end
end

function CreditsScene:onInputRelease(e)
	if e.scancode == "space" or e.type == "mouse" and e.button == 1 then
		self.increase_speed = false
	end
end

return CreditsScene
