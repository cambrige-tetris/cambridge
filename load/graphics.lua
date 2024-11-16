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

function loadImageTable(image_table, path_table)
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

---@param image love.Texture
---@param origin_x integer
---@param origin_y integer
---@param draw_width integer
---@param draw_height integer
function drawSizeIndependentImage(image, origin_x, origin_y, r, draw_width, draw_height, offset_x, offset_y, ...)
	offset_x = offset_x or 0
	offset_y = offset_y or 0
	local width, height = image:getDimensions()
	local width_scale_factor = width / draw_width
	local height_scale_factor = height / draw_height
	love.graphics.draw(image, origin_x, origin_y, r, 1/width_scale_factor, 1/height_scale_factor, offset_x*width_scale_factor, offset_y*height_scale_factor, ...)
end

--- this exists for less unnecessary typing
drawImage = drawSizeIndependentImage

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
