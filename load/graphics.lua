local image_formats = {"png", "jpg", "bmp", "tga"}

---Putting file format at the end isn't required. Also it supports resource pack system.
---@param path string
---@return love.Image
function loadImage(path)
	local is_packs_present = #config.resource_packs_applied > 0
	for _, v in pairs(image_formats) do
		local local_path = path.."."..v
		if love.filesystem.getInfo(local_path) then
			path = local_path
			if not is_packs_present then break end
		end
		if love.filesystem.getInfo(applied_packs_path..local_path) then
			path = applied_packs_path..local_path
			break
		end
	end
	if love.filesystem.getInfo(path) then
		-- this file exists
		return love.graphics.newImage(path)
	end
	error(("Image (%s) not found!"):format(path))
end

local function loadImageTable(image_table, path_table)
	for k,v in pairs(path_table) do
		if type(v) == "table" then
			image_table[k] = {}
			-- list of subimages
			for k2,v2 in pairs(v) do
				image_table[k][k2] = loadImage(v2)
			end
		else
			image_table[k] = loadImage(v)
		end
	end
end

--It's a pseudo-random string to avoid most folder collisions.
applied_packs_path = ""

backgrounds = {}
backgrounds_paths = {
	title = "res/backgrounds/title",
	title_no_icon = "res/backgrounds/title-no-icon",
	title_night = "res/backgrounds/title-night",
	snow = "res/backgrounds/snow",
	options_input = "res/backgrounds/options-input",
	options_game = "res/backgrounds/options-game",
}
current_playing_bgs = {}
extended_bgs = {}

local bgpath = "res/backgrounds/%s"

-- helper method to populate backgrounds
local function createBackgroundIfExists(name, path)
	local char_pos = path:gsub("\\", "/"):reverse():find("/")
	local file_name = path:sub(-char_pos+1)
	-- see if background is an extension of another background
	if extended_bgs[file_name] ~= nil then
		local copy_bg = extended_bgs[file_name]
		copy_bg = copy_bg / 100
		backgrounds[name] = backgrounds[copy_bg]
		return true
	end

	-- try creating video background
	local video_path = path .. ".ogv"
	if love.filesystem.getInfo(video_path) then
		backgrounds[name] = love.graphics.newVideo(
			video_path, {["audio"] = false}
		)
		-- you can set audio to true, but the video will not loop
		-- properly if audio extends beyond video frames
		return true
	end
	--loadImageTable already deals with loading images.
	if backgrounds[name] ~= nil then
		return true
	end
	return false
end

local function stopOtherBgs(bg)
	if #current_playing_bgs == 0 and bg:typeOf("Video") then
		current_playing_bgs[#current_playing_bgs+1] = bg
	end

	if #current_playing_bgs >= 1 then
		while current_playing_bgs[1] ~= bg and #current_playing_bgs >= 1 do
			current_playing_bgs[1]:pause()
			current_playing_bgs[1]:rewind()
			table.remove(current_playing_bgs, 1)
		end
	end

end

function fetchBackgroundAndLoop(id)
	local bg = backgrounds[id]

	if bg:typeOf("Video") and not bg:isPlaying() then
		bg:rewind()
		bg:play()
	end

	stopOtherBgs(bg)

	return bg
end

-- in order, the colors are:
-- red, orange, yellow, green, cyan, blue
-- magenta (or purple), white, black
-- the next three don't have colors tied to them
-- F is used for lock flash
-- A is a garbage block
-- X is an invisible "block"
-- don't use these for piece colors when making a ruleset
-- all the others are fine to use
blocks = {}
blocks_paths = {
	["2tie"] = {
		R = "res/img/s1",
		O = "res/img/s3",
		Y = "res/img/s7",
		G = "res/img/s6",
		C = "res/img/s2",
		B = "res/img/s4",
		M = "res/img/s5",
		W = "res/img/s9",
		D = "res/img/s8",
		F = "res/img/s9",
		A = "res/img/s8",
		X = "res/img/s9",
	},
	["bone"] = {
		R = "res/img/bone",
		O = "res/img/bone",
		Y = "res/img/bone",
		G = "res/img/bone",
		C = "res/img/bone",
		B = "res/img/bone",
		M = "res/img/bone",
		W = "res/img/bone",
		D = "res/img/bone",
		F = "res/img/bone",
		A = "res/img/bone",
		X = "res/img/bone",
	},
	["gem"] = {
		R = "res/img/gem1",
		O = "res/img/gem3",
		Y = "res/img/gem7",
		G = "res/img/gem6",
		C = "res/img/gem2",
		B = "res/img/gem4",
		M = "res/img/gem5",
		W = "res/img/gem9",
		D = "res/img/gem9",
		F = "res/img/gem9",
		A = "res/img/gem9",
		X = "res/img/gem9",
	},
	["square"] = {
		W = "res/img/squares",
		Y = "res/img/squareg",
		F = "res/img/squares",
		X = "res/img/squares",
	}
}

ColourSchemes = {
	Arika = {
		I = "R",
		L = "O",
		J = "B",
		S = "M",
		Z = "G",
		O = "Y",
		T = "C",
	},
	TTC = {
		I = "C",
		L = "O",
		J = "B",
		S = "G",
		Z = "R",
		O = "Y",
		T = "M",
	}
}

for name, blockset in pairs(blocks) do
	for shape, image in pairs(blockset) do
		image:setFilter("nearest")
	end
end

misc_graphics = {}
misc_graphics_paths = {
	frame = "res/img/frame",
	ready = "res/img/ready",
	go = "res/img/go",
	select_mode = "res/img/select_mode",
	strike = "res/img/strike",
	santa = "res/img/santa",
	icon = "res/img/cambridge_transparent"
}

-- Utility function to allow any size background to be used.
-- This will stretch the background to either 4:3, or screen's aspect ratio.
function drawBackground(id)
	local bg_object = fetchBackgroundAndLoop(id)
	local x, y, w, h = 0, 0, 640, 480
	if config.visualsettings.stretch_background == 2 then
		x, y = love.graphics.inverseTransformPoint(0, 0)
		local window_width, window_height = love.graphics.getDimensions()
		local scale_factor = math.min(window_width / 640, window_height / 480)
		w, h = window_width / scale_factor, window_height / scale_factor
	end
	drawSizeIndependentImage(bg_object, x, y, 0, w, h)
end


local previous_selected_packs = {}
local initial_load = true

function loadResources()
	local random_numbers = {}
	for i = 1, 32 do
		random_numbers[#random_numbers+1] = love.math.random(1, 127)
	end
	applied_packs_path = table.concat(random_numbers)
	if not initial_load and equals(previous_selected_packs, config.resource_packs_applied) then
		return
	end
	local resource_pack_indexes = {}
	local resource_packs = love.filesystem.getDirectoryItems("resourcepacks")
	for key, value in pairs(resource_packs) do
		if value:sub(-4) == ".zip" and love.filesystem.getInfo("resourcepacks/"..value, "file") then
			resource_pack_indexes[value] = key
		end
	end
	for k, v in pairs(previous_selected_packs) do
		love.filesystem.unmount("resourcepacks/"..v)
	end
	if type(config.resource_packs_applied) == "table" then
		for k, v in pairs(config.resource_packs_applied) do
			if resource_pack_indexes[v] then
				love.filesystem.mount("resourcepacks/"..v, applied_packs_path.."res/")
			elseif not previous_selected_packs[k] then
				table.remove(config.resource_packs_applied, k)
			end
		end
	end

	if not initial_load or #config.resource_packs_applied > 0 then
		love.graphics.setCanvas()
		love.graphics.clear()
		love.graphics.setFont(font_3x5_4)
		love.graphics.printf("Loading resource packs...", 0, 160, 640, "center")
		love.graphics.setColor(0, 0, 0, 0.5)
		love.graphics.present()
	end

	backgrounds = {}
	blocks = {}
	misc_graphics = {}
	backgrounds_paths = {
		title = "res/backgrounds/title",
		title_no_icon = "res/backgrounds/title-no-icon",
		title_night = "res/backgrounds/title-night",
		snow = "res/backgrounds/snow",
		options_input = "res/backgrounds/options-input",
		options_game = "res/backgrounds/options-game",
	}
	local previous_bg_index = 0
	local bg_index = 0
	while true do
		local formatted_bgpath = bgpath:format(tostring(bg_index*100))
		for key, value in pairs(image_formats) do
			if love.filesystem.getInfo(formatted_bgpath.."."..value) then
				backgrounds_paths[bg_index] = formatted_bgpath
				bg_index = bg_index + 1
				break
			end
		end
		if previous_bg_index == bg_index then
			break
		end
		previous_bg_index = bg_index
	end

	loadImageTable(backgrounds, backgrounds_paths)
	loadImageTable(blocks, blocks_paths)
	loadImageTable(misc_graphics, misc_graphics_paths)

	--#region Backgrounds stuff. Warning: Code duplication

	local function loadExtendedBgs()
		--Dynamic reloading, ey?
		package.loaded["res.backgrounds.extend_section_bg"] = nil
		extended_bgs = require("res.backgrounds.extend_section_bg")
	end

	-- error handling for if there is no extend_section_bg
	if pcall(loadExtendedBgs) then end

	-- create section backgrounds
	for key, value in pairs(backgrounds_paths) do
		createBackgroundIfExists(key, value)
	end
	--#endregion
	resetAppendedSoundPaths()
	generateSoundTable()
	generateBGMTable()

	collectgarbage("collect")

	initial_load = false

	previous_selected_packs = copy(config.resource_packs_applied)
end
