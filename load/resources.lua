local image_formats = {"png", "jpg", "bmp", "tga"}

--It's a pseudo-random string to avoid most folder collisions.
applied_packs_path = ""

local previous_selected_packs = {}
local initial_load = true

local bg_path = "res/backgrounds/%s"

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
		loadStandardFonts()
		love.graphics.setCanvas()
		love.graphics.clear()
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setFont(font_3x5_4)
		love.graphics.printf("Loading resource packs...", 0, 160, 640, "center")
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
		local formatted_bg_path = bg_path:format(tostring(bg_index*100))
		for key, value in pairs(image_formats) do
			if love.filesystem.getInfo(formatted_bg_path.."."..value) then
				backgrounds_paths[bg_index] = formatted_bg_path
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

	--#region Backgrounds stuff.

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
